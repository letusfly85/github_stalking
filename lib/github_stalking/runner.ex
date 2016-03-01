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
        Logger.info(GithubStalking.Issue.show_issues(repo_full_path))

      [collect: collect] -> 
        GithubStalking.IssueSpecifier.collect_repos_info
    end
  end
end
