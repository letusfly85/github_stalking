defmodule GithubStalking.Slack do
  @moduledoc"""
  """
  require Logger

  alias GithubStalking.Github.Issue

  @doc"""
  """
  def generate_json_data(repo_full_path, issue) do
    repo_full_path_with_number = 
      repo_full_path   <> "/issues/" <> Integer.to_string(issue.number) 
    text = issue.title <> "\nupdated_at: " <> issue.updated_at

    linked_text = "<https://github.com/" <> repo_full_path_with_number <>
                  "|" <> repo_full_path_with_number <> ">"
    Logger.info(inspect issue.comments)

    {comment_detail, comment_color} = 
    case is_integer(issue.comments) do
      true ->
        comment_detail = repo_full_path_with_number <> " doesn't have comments yet..."

        {comment_detail, "#d29ac6"}
      _  ->
        comment_detail = "comment count:       " <>
          Integer.to_string(issue.comments["comment_count"]) <> "\n" <>
          "participant count:   " <> Integer.to_string(issue.comments["participant_count"])
        
        {comment_detail, "#ddd6ca"}
    end
 
    json_data = %{channel:    "#github_extra", 
                  username:   "github_extra",
                  text:       linked_text,
                  attachments: [
                    %{color:    "#36a64f",
                      text: text,
                      thumb_url: issue.avatar_url
                    },
                    %{color:  comment_color,
                      text:   comment_detail
                    }
                  ],
                  icon_emoji: ":ghost:"} |> Poison.encode!
    json_data
  end

  @doc"""
  """
  def notify_update_issues(repo_full_path) do
    prob_issues = Issue.find_issues(repo_full_path)
    case prob_issues do
      {:ok, issues} ->
        headers = []
        result = Enum.reduce(issues, [], fn(issue, acc) ->
          json_data = generate_json_data(repo_full_path, issue) 
          response = HTTPoison.post!(System.get_env("slack_webhook_url"), json_data, headers)

          #TODO show status code and repository name only
          Logger.info "response: #{inspect response}"

          [Map.put(Map.from_struct(issue), :is_notified, true)|acc]
        end) 
        
        Issue.register_issues(repo_full_path, result)

      {:error, _}   ->
          Logger.error "there is no issues..."
    end
  end

end
