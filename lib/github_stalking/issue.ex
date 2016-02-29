defmodule GithubStalking.Issue do
  @derive [Poison.Encoder]
  defstruct [:number, :title, :updated_at, :owner, :repo]

  def show_issues(repo_full_path) do
    obj = Riak.find(GithubStalking.Riak.get_pid, "issue_numbers", repo_full_path)
    case obj do
      nil -> IO.inspect("there is no issues")
      _   ->
        result = Poison.decode!(obj.data, as: %GithubStalking.Issues{})
        case result.numbers do
          [] -> IO.inspect("there is no issues")
          _  -> Enum.each(result.numbers, fn(number) ->
                  path = repo_full_path <> "/" <> to_string(number)

                  obj = Riak.find(GithubStalking.Riak.get_pid, "issue_history", path) 
                  case obj do
                    nil -> IO.inspect("there is no issues")
                    _ -> 
                     issue = Poison.decode!(obj.data, as: %GithubStalking.Issue{})
                     IO.inspect(issue)
                  end
                end)
          end
    end

  end

end

