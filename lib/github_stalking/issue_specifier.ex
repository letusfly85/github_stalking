defmodule GithubStalking.IssueSpecifier do

  @doc"""
  """
  def search_update_repositories(owner, repo, pre_issues) do
    cur_issues = Tentacat.Issues.filter(owner, repo, @client)

    issues = []
    Enum.each(cur_issues, fn(cur_issue) ->
      cur_number = cur_issue[:number]
      pre_issue = pre_issues[cur_number]

      if cur_issue[:updated_at] > pre_issue[:update_at] do
        issues = [cur_issue, issues]
      end
    end)

    issues
  end

end
