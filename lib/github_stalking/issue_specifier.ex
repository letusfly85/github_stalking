defmodule GithubStalking.IssueSpecifier do
  @client Tentacat.Client.new(
    System.get_env("access_token") || Application.get_env(:github_stalking, :access_token)
  )

  @doc"""
  search updated issues from pre searched
  """
  def updated_open_issues(owner, repo, pre_issues) do
    cur_issues = Tentacat.Issues.filter(owner, repo, %{state: "open"}, @client)

    Enum.filter(cur_issues, fn(cur_issue) ->
      number = cur_issue["number"]
      pre_issues[number] != nil
    end) |> Enum.reduce([], fn(cur_issue, issues) ->
      number = cur_issue["number"]
      pre_issue = pre_issues[number]

      if cur_issue["updated_at"] > pre_issue.updated_at do
        [cur_issue|issues]
      end
    end)
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
  TODO
  """
  def collect_repos_info do
    GithubStalking.Repository.find_pre_issues_repos()
    |> GithubStalking.Riak.issues_numbers
    |> Enum.each(fn(issue_numbers) ->
         repo_full_path = issue_numbers.repo_full_path
         pre_issues_map = GithubStalking.Riak.find_pre_issues_map(issue_numbers)

         if (length pre_issues_map) > 0 do
           owner = (hd issue_numbers).owner
           repo  = (hd issue_numbers).repo

           updated_open_issues(owner, repo, pre_issues_map)
         end
       end)
  end

end
