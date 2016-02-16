defmodule GithubStalking.Riak do

  @doc"""
  """
  def get_pid do
    {:ok, pid } = Riak.Connection.start('127.0.0.1', 8087)    
    pid
  end

  @doc"""
  """
  def find_pre_issues() do
    {:ok, keys} = Riak.Bucket.keys(GithubStalking.Riak.get_pid, "issue_numbers")

    issues_numbers = keys |> Enum.reduce([], fn(key, acc) ->
      obj = Riak.find(GithubStalking.Riak.get_pid, "issue_numbers", key)
      issue_numbers = Poison.decode!(obj.data, as: %GithubStalking.Issues{})
      if (hd issue_numbers.numbers) != nil do
        [issue_numbers|acc]
      end
    end)

    result = issues_numbers
    |> Enum.filter(fn(issue_numbers) ->
      issue = find_pre_issues_numbers(issue_numbers)
      (hd issue) != nil
    end)
    |> Enum.reduce([], fn(issue_numbers, acc) ->
      find_pre_issues_numbers(issue_numbers) ++ acc
    end)

    result
  end
  
  @doc"""
  """
  def find_pre_issues_numbers(issue_numbers) do
    issue_numbers.numbers |> Enum.reduce([], fn(number, acc) ->
      path = issue_numbers.repo_full_path <> "/" <> to_string(number)
      [Riak.find(GithubStalking.Riak.get_pid, "issue_history", path)|acc]
    end)
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

end
