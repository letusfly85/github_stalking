defmodule GithubStalking do
  @moduledoc"""
  """

  require Logger

  @doc"""
  """
  def auto_collect(i) do
    :timer.sleep(1000)
    Logger.info(i)
    case i do
      nil -> auto_collect2(1)
      x ->   auto_collect2(x+1)
    end
  end

  @doc"""
  """
  def auto_collect() do
    target_repos = Application.get_env(:github_stalking, :target_repos)
    Enum.each(target_repos, fn(repo_full_path) ->
      GithubStalking.Github.Issue.collect_repos_info(repo_full_path)
      GithubStalking.Slack.notify_update_issues(repo_full_path)
    end)
  end

  def main(args) do
    {options, _, _} = OptionParser.parse(args,
      switches: [register: :string, collect: :string],
      aliases:  [r: :register,      c: :collect]
    )

    try do
        GithubStalking.Runner.run(options)
    rescue
      e in RuntimeError -> e
        IO.puts e.message
    end
  end
end
