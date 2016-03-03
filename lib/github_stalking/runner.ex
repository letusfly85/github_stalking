defmodule GithubStalking.Runner do
  @moduledoc"""
  """
  require Logger

  def run(options) do
    case options do
      [register: repo_full_path] -> 
        GithubStalking.Repository.register_repo(repo_full_path)

      [show_repos: show_repos] ->
        Logger.info(GithubStalking.Repository.target_repos)
        
      [show_issues: repo_full_path] ->
        issues = GithubStalking.Issue.show_issues(repo_full_path)
        Enum.each(issues, fn(issue) ->
          Logger.info(issue.title)
        end)

      [collect: collect] -> 
        GithubStalking.IssueSpecifier.collect_repos_info

      [notify2slack: repo_full_path] -> 
        Logger.info(repo_full_path)
        GithubStalking.Slack.notify_update_issues(repo_full_path)
    end
  end
end
