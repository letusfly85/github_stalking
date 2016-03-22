defmodule GithubStalking.Github.Issue do
  @moduledoc"""
  """
  require Logger

  @client Tentacat.Client.new(%{access_token: System.get_env("access_token")})

  @derive [Poison.Encoder]
  defstruct [:number, :title, :updated_at, :owner, :repo, :is_notified, :avatar_url]
  
  @doc"""
  """
  def show_issues(repo_full_path) do
    result = GithubStalking.Github.Issue.find_issues(repo_full_path)
    case result do
      {:ok, issues} -> 
        Enum.each(issues, fn(issue) ->
          Logger.info("show:##### " <> issue.updated_at <> " " <> issue.title)
        end)
      {:error, _} ->
        Logger.error("there is no issues...")
    end
  end

  @doc"""
  """
  def find_issues(repo_full_path) do
    obj = Riak.find("issue_numbers", repo_full_path)

    case obj do
      nil ->
        Logger.error(repo_full_path <> " doesn't have any issues")
        {:error, []}

      _   ->
        issue_numbers = Poison.decode!(obj.data, as: %GithubStalking.Github.IssueNumbers{})
        {:ok, find_issues_details(issue_numbers)}
    end
  end

  def find_issues_details(issue_numbers) do
    issue_list = Enum.reduce(issue_numbers.numbers, [], fn(number, issues) ->
      path = issue_numbers.repo_full_path <> "/" <> to_string(number)

      obj = Riak.find("issue_history", path) 
      case obj do
        nil ->
          Logger.error(":error##### cannot get info from " <> path)
          issues

        _   -> 
          issue = Poison.decode!(obj.data, as: %GithubStalking.Github.Issue{})
          [issue|issues]
      end
    end)
    
    Enum.filter(issue_list, fn(issue) ->
      issue.is_notified == false
    end)
  end

  @doc"""
  find pre issues list of a specified repository
  """
  def find_pre_issues(issue_numbers) do
    pre_issues = issue_numbers.numbers |> Enum.reduce([], fn(number, acc) ->
      path = issue_numbers.repo_full_path <> "/" <> to_string(number)
      obj = Riak.find("issue_history", path) 

      #TODO add test case when obj is nil
      case obj do
        nil -> acc

        _ -> 
         issue = Poison.decode!(obj.data, as: %GithubStalking.Github.Issue{})
         [issue|acc]
      end
    end)

    Enum.reduce(pre_issues, [], fn(issue, acc) ->
      case issue.is_notified do
        nil -> [Map.merge(issue, %GithubStalking.Github.Issue{is_notified: false})|acc]
        _   -> [issue|acc]
      end
    end)
  end

  @doc"""
  find pre issues map of a specified repository
  """
  def find_pre_issues_map(issue_numbers) do
    pre_issues = find_pre_issues(issue_numbers)
    Enum.reduce(pre_issues, %{}, fn(pre_issue, acc) ->
      Map.put(acc, pre_issue.number, pre_issue)
    end)
  end

  @doc"""
  """
  def updated_open_issues(repo_full_path, pre_issues) do
    ary = String.split(repo_full_path, "/")
    owner = Enum.at(ary, 0)
    repo  = Enum.at(ary, 1)

    updated_open_issues(owner, repo, pre_issues)
  end

  @doc"""
  search updated issues from pre searched
  """
  def updated_open_issues(owner, repo, pre_issues) do
    Logger.info("search issues from " <> owner <> "/" <> repo)
    try do
      response = Tentacat.Issues.filter(owner, repo, %{state: "open"}, @client)

      #TODO add test case for 404 pattern
      case response do
        {403, _} -> raise("it seems that you exceed limitaion of GitHub API request.")
        {404, _} -> raise(owner <> "/" <> repo <> " doesn't have open issues.")

        _          -> 
          issues = Enum.reduce(response, [], fn(current_issue, acc) ->
                     generate_issues(current_issue, pre_issues, acc)
                   end)
          {:ok, issues}
      end

    rescue
      e in RuntimeError ->
        Logger.error(e.message)
        {:error, []}

      e in HTTPoison.Error ->
        Logger.error(e.message)
        {:error, []}

      e in UndefinedError ->
        Logger.error(e.message)
        {:error, []}
    end
  end

  defp generate_issues(current_issue, pre_issues, acc) do
    number = current_issue["number"]
    new_cur_issue = 
      for {key, _} <- Map.from_struct(GithubStalking.Github.Issue.__struct__()), into: %{},
                        do: {key, current_issue[Atom.to_string(key)]}
    issue = struct(GithubStalking.Github.Issue, new_cur_issue)
    issue = Map.put(issue, :avatar_url, current_issue["user"]["avatar_url"])

    case pre_issues[number] do
      nil ->
        issue = Map.put(issue, :is_notified, false)
        [issue|acc]

      pre_issue   ->
        case issue.updated_at > pre_issue.updated_at do
          true ->
            issue = Map.put(issue, :is_notified, false)
            [issue|acc]
          _    -> 
            pre_issue = Map.put(pre_issue, :avatar_url, current_issue["user"]["avatar_url"])
            [pre_issue|acc]
        end
    end
  end

  @doc"""
  find issue detail
  """
  def find_cur_issue(owner, repo, pre_issue) do
    {number, _} = pre_issue
    pre_issue_number = Integer.to_string(number)
    
    response = Tentacat.Issues.find(owner, repo, pre_issue_number, @client) 
    case response do
      {403, _} ->
        Logger.error("it seems that you exceed limitation of GitHub API.")
        {:error, []}

      _ ->
        {:ok, response}
    end
  end

  @doc"""
  search closed issues compared with pre searched
  """
  def closed_issues(owner, repo, pre_issues) do
    pre_issues_list = Map.to_list(pre_issues)

    response_list =  Enum.reduce(pre_issues_list, [], fn(pre_issue, issues) ->
      [find_cur_issue(owner, repo, pre_issue)|issues]
    end)

    closed_issue_list = Enum.reduce(response_list, [], fn(response, issues) ->
      case response do
        {:ok, response} ->
          [response|issues]

        {:error, _} ->
          Logger.error("something wrong happen..")
      end
    end)
    
    {:ok, Enum.filter(closed_issue_list, fn(issue) -> issue["state"] == "closed" end)}
  end

  @doc"""
  """
  def collect_repos_info(repo_full_path) do
    prob_issue_numbers = GithubStalking.Github.IssueNumbers.find_issues_numbers(repo_full_path)
    case prob_issue_numbers do
      {:ok, issue_numbers} ->
        pre_issues_map = GithubStalking.Github.Issue.find_pre_issues_map(issue_numbers)

        prob_issues = updated_open_issues(repo_full_path, pre_issues_map)
        case prob_issues do
          {:ok, issues} ->
            Logger.info(":start  collecting issues ### " <> repo_full_path)
            
            GithubStalking.Github.Issue.register_issues(repo_full_path, issues)
            GithubStalking.Github.IssueNumbers.register_issue_numbers(repo_full_path, issues)

            Logger.info(":finish collecting issues ### " <> repo_full_path)

          {:error, _}   ->
            GithubStalking.Github.Issue.register_issues(repo_full_path, [])
        end

      {:error, _} ->
        Logger.error("it seems that there is no issue or no entry for " <> repo_full_path)
    end
  end
  
  @doc"""
  """
  def register_issues(repo_full_path, issues) do
    Enum.each(issues, fn(issue) ->
      repo_full_path_with_number = repo_full_path <> "/" <> to_string(issue.number)
      Logger.info(":start register issue ### " <> repo_full_path_with_number)

      case issue.is_notified do
        true -> issue = Map.put(issue, :is_notified, true)
        _    -> issue = Map.put(issue, :is_notified, false)
      end
      obj = Riak.Object.create(bucket: "issue_history", key: repo_full_path_with_number, data: Poison.encode!(issue))
      Riak.put(obj)

      Logger.info(":finish register issue ### " <> repo_full_path_with_number <> 
                  " " <> issue.updated_at <> " " <> to_string(issue.is_notified) <> " " <> issue.title)
    end)
  end

  @doc"""
  """
  def register_issues(owner, repo, issues) do
    repo_full_path = owner <> "/" <> repo
    register_issues(repo_full_path, issues)
  end
end
