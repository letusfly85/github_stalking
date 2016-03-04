defmodule GithubStalking.Runner do
  @moduledoc"""
  """
  require Logger

  @doc"""
  """
  def run(options) do
    case options do
      [register: repo_full_path] -> 
        GithubStalking.Github.Repository.register_repo(repo_full_path)

      [show_repos: show_repos] ->
        repos = GithubStalking.Github.Repository.target_repos
        Enum.each(repos, fn(repo) -> Logger.info(repo) end)
        
      [show_issues: repo_full_path] ->
        GithubStalking.Github.Issue.show_issues(repo_full_path)

      [collect: collect] -> 
        case collect do
          "all"   -> GithubStalking.Github.Issue.collect_repos_info 
          collect -> GithubStalking.Github.Issue.collect_repos_info(collect)
        end

      [notify2slack: repo_full_path] -> 
        GithubStalking.Slack.notify_update_issues(repo_full_path)
    end
  end
end
