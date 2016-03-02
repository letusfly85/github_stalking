defmodule GithubStalking.Issue do
  @moduledoc"""
  """
  require Logger

  @derive [Poison.Encoder]
  defstruct [:number, :title, :updated_at, :owner, :repo]

  def show_issues(repo_full_path) do
    obj = Riak.find(GithubStalking.Riak.get_pid, "issue_numbers", repo_full_path)

    result = nil 
    case obj do
      nil -> Logger.info(repo_full_path <> " doesn't have any issues")
      _   ->
        result = Poison.decode!(obj.data, as: %GithubStalking.Issues{})
    end

    issue_numbers = Enum.filter(result.numbers, fn(numbers) -> numbers != [] end)
    Enum.reduce(issue_numbers, [], fn(number, issues) ->
      path = repo_full_path <> "/" <> to_string(number)

      obj = Riak.find(GithubStalking.Riak.get_pid, "issue_history", path) 
      case obj do
        nil ->
          Logger.info("cannot get info from " <> path)
          issues
        _   -> 
          issue = Poison.decode!(obj.data, as: %GithubStalking.Issue{})
          Logger.info(issue.title)
          [issue|issues]
      end
    end)
  end

end
