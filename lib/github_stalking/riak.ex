defmodule GithubStalking.Riak do

  @doc"""
  """
  def get_pid do
    {:ok, pid } = Riak.Connection.start('127.0.0.1', 8087)    
    pid
  end

  @doc"""
  """
  def register_numbers(issues, owner, repo) do
    repo_full_path = owner <> "/" <> repo
    numbers = issues |> Enum.reduce([], fn(issue, acc) ->
      [issue["number"]|acc] 
    end)
    issues_numbers = %GithubStalking.Issues{repo_full_path: repo_full_path, numbers: numbers}
    obj = Riak.Object.create(bucket: "issue_numbers", key: repo_full_path, data: Poison.encode!(issues_numbers))
    Riak.put(get_pid, obj)
  end

  @doc"""
  """
  def register(issues, owner, repo) do
    Enum.each(issues, fn(issue) ->
      repo_full_path = owner <> "/" <> repo <> "/" <> to_string(issue["number"])
      obj = Riak.Object.create(bucket: "issue_history", key: repo_full_path, data: Poison.encode!(issue))
      Riak.put(get_pid, obj)
    end)
  end

  @doc"""
  """
  def find_pre_issues(issue_numbers) do
    issue_numbers.numbers |> Enum.reduce([], fn(number, acc) ->
      path = issue_numbers.repo_full_path <> "/" <> to_string(number)
      [Riak.find(GithubStalking.Riak.get_pid, "issue_history", path)|acc]
    end)
  end
end
