defmodule GithubStalking.IssueSpecifier do
  require Logger

  @client Tentacat.Client.new(System.get_env("access_token"))

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

        Enum.reduce([], response, fn(current_issue, issues) ->
          number = current_issue["number"]

          case pre_issues[number] do
            nil -> [current_issue|issues]
            _ ->
              case current_issue["updated_at"] > pre_issues.updated_at do
                true -> [current_issue|issues]
                _ -> issues
              end
          end
        end)
      end

    rescue
      e in RuntimeError ->
            Logger.info(e.message)
            []

      e in UndefinedError ->
            Logger.info(e.message)
            []
    end

  end

  @doc"""
  find issue detail
  """
  def cur_issue(owner, repo, pre_issue) do
    {number, _} = pre_issue
    pre_issue_number = Integer.to_string(number)
    
    Tentacat.Issues.find(owner, repo, pre_issue_number, @client) 
  end

  @doc"""
  search closed issues compared with pre searched
  """
  def closed_issues(owner, repo, pre_issues) do
    Enum.filter(Map.to_list(pre_issues), fn(pre_issue) ->
      cur_issue(owner, repo, pre_issue)["state"] == "closed"
    end) |> Enum.reduce([], fn(pre_issue, issues) ->
      [cur_issue(owner, repo, pre_issue)|issues]
    end)
  end

  @doc"""
  """
  def collect_repos_info do
    GithubStalking.Repository.target_repos()
    |> GithubStalking.Riak.issues_numbers
    |> Enum.each(fn(issue_numbers) ->
         repo_full_path = issue_numbers.repo_full_path
         pre_issues_map = GithubStalking.Riak.find_pre_issues_map(issue_numbers)

         issues = updated_open_issues(repo_full_path, pre_issues_map)
         GithubStalking.Riak.register(repo_full_path, issues)
       end)
  end

end
