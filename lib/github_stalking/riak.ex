defmodule GithubStalking.Riak do

  @doc"""
  """
  def get_pid do
    {:ok, pid } = Riak.Connection.start('127.0.0.1', 8087)    
    pid
  end

  @doc"""
  """
  def register(issues) do
    Enum.each(issues, fn(issue) ->
      obj = Riak.Object.create(bucket: "issue_history", key: "letusfly85/github_stalking", data: Poison.encode!(issue))
      Riak.put(get_pid, obj)
    end)
  end

end
