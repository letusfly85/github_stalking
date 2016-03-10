defmodule GithubStalking.Runner do
  @moduledoc"""
  """
  use GenServer
  require Logger

  @doc"""
  """
  def run(options) do
    case options do
      [register: repo_full_path] -> 
        GithubStalking.Github.Repository.register_repo(repo_full_path)

      [show_repos: _] ->
        repos = GithubStalking.Github.Repository.target_repos
        Enum.each(repos, fn(repo) -> Logger.info(repo) end)
        
      [show_issues: repo_full_path] ->
        GithubStalking.Github.Issue.show_issues(repo_full_path)

      [collect: repo_full_path] -> 
        GithubStalking.Github.Issue.collect_repos_info(repo_full_path)

      [notify2slack: repo_full_path] -> 
        GithubStalking.Slack.notify_update_issues(repo_full_path)
    end
  end

  def start_link do
    GenServer.start_link(__MODULE__, HashDict.new, name: :github_stalking)
  end

  def collect(server, repo_full_path) do
    GenServer.call(server, {:collect, repo_full_path})
  end

  def handle_call({:collect, repo_full_path}, _from, state) do
    Logger.info(repo_full_path)
    {:reply, GithubStalking.Github.Issue.collect_repos_info(repo_full_path), state}
  end

  def handle_call({:lookup, key}, _from, state) do
    {:reply, state[key], state}
  end

  def handle_call({:notify2slack, repo_full_path}, _from, state) do
    {:reply, 
        GithubStalking.Slack.notify_update_issues(repo_full_path), state
    }
  end
end
