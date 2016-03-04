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
  def generate_json_data(repo_full_path, issue) do
    repo_full_path_with_number = repo_full_path   <> "/issues/" <> Integer.to_string(issue.number) 
    text = issue.title <>
           "\nupdated_at: " <> issue.updated_at

    linked_text = "<https://github.com/" <> repo_full_path_with_number <>
                  "|" <> repo_full_path_with_number <> ">"
 
    json_data = %{channel:    "#github_extra", 
                  username:   "github_extra",
                  text:       linked_text,
                  attachments: [
                    %{color:    "#36a64f",
                      text: text,
                      #image_url: issue.avatar_url,
                      thumb_url: issue.avatar_url
                    }
                  ],
                  icon_emoji: ":ghost:"} |> Poison.encode!
    json_data
  end

  @doc"""
  """
  def notify_update_issues(repo_full_path) do
    issues = GithubStalking.Github.Issue.find_issues(repo_full_path)
    headers = []
    Logger.info(System.get_env("slack_webhook_url"))
    Logger.info(@slack_webhook_url)
    result = Enum.reduce(issues, [], fn(issue, acc) ->
      json_data = generate_json_data(repo_full_path, issue) 
      response = HTTPoison.post!(@slack_webhook_url, json_data, headers)
      Logger.info "response: #{inspect response}"
      Map.merge(issue, %GithubStalking.Github.Issue{is_notified: true})
      [Map.put(Map.from_struct(issue), :is_notified, true)|acc]
    end) 
    
    GithubStalking.Github.Issue.register_issues(repo_full_path, result)
  end

end
