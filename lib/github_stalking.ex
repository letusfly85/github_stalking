defmodule GithubStalking do
  @moduledoc"""
  """

  require Logger
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(GithubStalking.Runner, [])
    ]

    opts = [strategy: :one_for_one, name: GithubStalking.Runner]
    Supervisor.start_link(children, opts)
  end

  @doc"""
  """
  def auto_collect() do
    target_repos = Application.get_env(:github_stalking, :target_repos)
    Enum.each(target_repos, fn(repo_full_path) ->
      try do
      Logger.info(":start##" <> repo_full_path)

      GithubStalking.Github.Issue.collect_repos_info(repo_full_path)
      GithubStalking.Slack.notify_update_issues(repo_full_path)

      Logger.info(":finish##" <> repo_full_path)
      
      rescue
        e in RuntimeError ->
          Logger.error(e.message)
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
