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
    issues = GithubStalking.Github.Issue.find_issues(repo_full_path)
    headers = []
    Logger.info(System.get_env("slack_webhook_url"))
    Logger.info(@slack_webhook_url)
    result = Enum.reduce(issues, [], fn(issue, acc) ->
      text = "https://github.com/" <> repo_full_path <> "/issues/" <> Integer.to_string(issue.number) <> "\ntitle: " <> issue.title <> ", updated_at: " <> issue.updated_at 
      json_data = %{channel:    "#github_extra", 
                    username:   "github_extra",
                    text:       text,
                    icon_emoji: ":ghost:"} |> Poison.encode!

      response = HTTPoison.post!(@slack_webhook_url, json_data, headers)
      Logger.info "response: #{inspect response}"
      Map.merge(issue, %GithubStalking.Github.Issue{is_notified: true})
      [Map.put(Map.from_struct(issue), :is_notified, true)|acc]
    end) 
    
    GithubStalking.Github.Issue.register_issues(repo_full_path, result)
  end

end
