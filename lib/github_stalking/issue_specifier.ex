defmodule GithubStalking.IssueSpecifier do
  @client Tentacat.Client.new

  @doc"""
  """
  def search_update_repositories(owner, repo, pre_issues) do
    cur_issues = Tentacat.Issues.filter(owner, repo, %{state: "open"}, @client)

    Enum.filter(cur_issues, fn(cur_issue) ->
      number = cur_issue["number"]
      pre_issue = pre_issues[number]
      
      pre_issue != nil
    end) |> Enum.reduce([], fn(cur_issue, issues) ->
      number = cur_issue["number"]
      pre_issue = pre_issues[number]

      if cur_issue["updated_at"] > pre_issue["update_at"] do
        [cur_issue|issues]
      end
    end)
  end

end
