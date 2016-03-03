defmodule GithubStalking.Github.Issue do
  @moduledoc"""
  """
  require Logger

  @client Tentacat.Client.new(System.get_env("access_token"))

  @derive [Poison.Encoder]
  defstruct [:number, :title, :updated_at, :owner, :repo, :is_notified]

  def find_issues(repo_full_path) do
    obj = Riak.find(GithubStalking.Riak.get_pid, "issue_numbers", repo_full_path)

    result = nil 
    case obj do
      nil -> Logger.info(repo_full_path <> " doesn't have any issues")
      _   ->
        result = Poison.decode!(obj.data, as: %GithubStalking.Github.IssueNumbers{})
    end

    issue_numbers = Enum.filter(result.numbers, fn(numbers) -> numbers != [] end)
    issue_list = Enum.reduce(issue_numbers, [], fn(number, issues) ->
      path = repo_full_path <> "/" <> to_string(number)

      obj = Riak.find(GithubStalking.Riak.get_pid, "issue_history", path) 
      case obj do
        nil ->
          Logger.info("cannot get info from " <> path)
          issues
        _   -> 
          issue = Poison.decode!(obj.data, as: %GithubStalking.Github.Issue{})
          Logger.info(issue.title)
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
      obj = Riak.find(GithubStalking.Riak.get_pid, "issue_history", path) 

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
        false -> [issue|acc]
        true  -> acc
        _ -> [Map.merge(issue, %GithubStalking.Github.Issue{is_notified: false})|acc]
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

        {:ok, Enum.reduce([], response, fn(current_issue, issues) ->
          number = current_issue["number"]

          case pre_issues[number] do
            nil -> [current_issue|issues]
            _ ->
              case current_issue["updated_at"] > pre_issues.updated_at do
                true -> [current_issue|issues]
                _ -> issues
              end
          end
        end)}
      end

    rescue
      e in RuntimeError ->
            Logger.info(e.message)
            {:error, []}

      e in UndefinedError ->
            Logger.info(e.message)
            {:error, []}
    end

  end

  @doc"""
  find issue detail
  """
  def cur_issue(owner, repo, pre_issue) do
    {number, _} = pre_issue
    pre_issue_number = Integer.to_string(number)
    
    response = Tentacat.Issues.find(owner, repo, pre_issue_number, @client) 
    case response do
      {403, _} ->
        Logger.info("it seems that you exceed limitation of GitHub API.")
        {:error, []}
      _ -> {:ok, response}
    end
  end

  @doc"""
  search closed issues compared with pre searched
  """
  def closed_issues(owner, repo, pre_issues) do
    pre_issues_list = Map.to_list(pre_issues)

    response_list =  Enum.reduce(pre_issues_list, [], fn(pre_issue, issues) ->
      [cur_issue(owner, repo, pre_issue)|issues]
    end)

    closed_issue_list = Enum.reduce(response_list, [], fn(response, issues) ->
      case response do
        {:ok, response} ->
          [response|issues]
        {:error, _} ->
          Logger.info("something wrong happen..")
      end
    end)
    
    {:ok, Enum.filter(closed_issue_list, fn(issue) -> issue["state"] == "closed" end)}
  end

  @doc"""
  """
  def collect_repos_info do
    GithubStalking.Github.Repository.target_repos()
    |> GithubStalking.Github.IssueNumbers.find_issues_numbers
    |> Enum.each(fn(issue_numbers) ->
        repo_full_path = issue_numbers.repo_full_path
        pre_issues_map = GithubStalking.Github.Issue.find_pre_issues_map(issue_numbers)

        result = updated_open_issues(repo_full_path, pre_issues_map)
        case result do
          {:ok, issues} ->
            Logger.info("collected " <> repo_full_path <> " info")
            GithubStalking.Github.Issue.register_issues(repo_full_path, issues)
            GithubStalking.Github.IssueNumbers.register_issue_numbers(repo_full_path, issues)
          {:error, _}   ->
            GithubStalking.Github.Issue.register_issues(repo_full_path, [])
        end
      end)
  end
  
  @doc"""
  """
  def register_issues(repo_full_path, issues) do
    Enum.each(issues, fn(issue) ->
      repo_full_path_with_number = repo_full_path <> "/" <> to_string(issue["number"])
      case issue["is_notified"] do
        nil -> issue = Map.merge(issue, %{"is_notified" => false})
      end
      obj = Riak.Object.create(bucket: "issue_history", key: repo_full_path_with_number, data: Poison.encode!(issue))
      Riak.put(GithubStalking.Riak.get_pid, obj)
      Logger.info("registered " <> repo_full_path_with_number)
    end)
  end

  @doc"""
  """
  def register_issues(owner, repo, issues) do
    repo_full_path = owner <> "/" <> repo
    register_issues(repo_full_path, issues)
  end
end
