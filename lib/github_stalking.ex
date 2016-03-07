defmodule GithubStalking do
  @moduledoc"""
  """

  require Logger

  @doc"""
  """
  def run() do
    run(0)
  end
  def run(x) do
    :timer.sleep(30000)
    Logger.info(x)
    run(x+1)
  end

  @doc"""
  """
  def auto_collect() do
    target_repos = Application.get_env(:github_stalking, :target_repos)
    Enum.each(target_repos, fn(repo_full_path) ->
      try do
      GithubStalking.Github.Issue.collect_repos_info(repo_full_path)
      GithubStalking.Slack.notify_update_issues(repo_full_path)

      Logger.info("done")
      
      rescue
        e in RuntimeError ->
          Logger.info(e.message)
      end
    end)

    :ok
  end

  def main(args) do
    {options, _, _} = OptionParser.parse(args,
      switches: [register: :string, collect: :string],
      aliases:  [r: :register,      c: :collect]
    )

    GithubStalking.Runner.run(options)
  end
end
