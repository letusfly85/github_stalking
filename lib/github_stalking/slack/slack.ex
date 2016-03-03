defmodule GithubStalking.Slack do
  @moduledoc"""
  """
  require Logger

  @slack_webhook_url System.get_env("slack_webhook_url")

  @doc"""
  """
  def notify_update_issues do
    #TODO
  end

  @doc"""
  """
  def notify_update_issues(repo_full_path) do
    issues = GithubStalking.Issue.show_issues(repo_full_path)
    headers = []
    Logger.info(@slack_webhook_url)
    Enum.each(issues, fn(issue) ->
      text = "https://github.com/" <> repo_full_path <> "/issues/" <> Integer.to_string(issue.number) <> "\ntitle: " <> issue.title <> ", updated_at: " <> issue.updated_at 
      json_data = %{channel:    "#github_extra", 
                    username:   "github_extra",
                    text:       text,
                    icon_emoji: ":ghost:"} |> Poison.encode!

      response = HTTPoison.post!(@slack_webhook_url, json_data, headers)
      Logger.info "response: #{inspect response}"
    end)
  end

end
