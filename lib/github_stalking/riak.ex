defmodule GithubStalking.Riak do

  @doc"""
  pid for riak connection
  """
  def get_pid do
    {:ok, pid} = Riak.Connection.start('127.0.0.1', 8087)    
    pid
  end

  @doc"""
  search issue list from issue_numbers
  """
  def issues_numbers(repo_full_path_list) do
    repo_full_path_list |> Enum.reduce([], fn(repo_full_path, acc) ->
      obj = Riak.find(GithubStalking.Riak.get_pid, "issue_numbers", repo_full_path)

      case obj do
        nil -> acc
        _   ->
          result = Poison.decode!(obj.data, as: %GithubStalking.Issues{})
          [result|acc]
      end
    end)
  end

  @doc"""
  find pre issues list of a specified repository
  """
  def find_pre_issues(issue_numbers) do
    issue_numbers.numbers |> Enum.reduce([], fn(number, acc) ->
      path = issue_numbers.repo_full_path <> "/" <> to_string(number)
      obj = Riak.find(GithubStalking.Riak.get_pid, "issue_history", path) 

      #TODO add test case when obj is nil
      case obj do
        nil -> acc
        _ -> 
         issue = Poison.decode!(obj.data, as: %GithubStalking.Issue{})
         [issue|acc]
      end
    end)
  end

  @doc"""
  find pre issues map of a specified repository
  """
  def find_pre_issues_map(issue_numbers) do
    find_pre_issues(issue_numbers)
    |> Enum.reduce(%{}, fn(pre_issue, acc) ->
      Map.put(acc, pre_issue.number, pre_issue)
    end)
  end

  @doc"""
  """
  def register_numbers(issues, owner, repo) do
    repo_full_path = owner <> "/" <> repo
    pre_numbers = []
    pre_issues = issues_numbers([repo_full_path])
    if pre_issues != nil and pre_issues != [] do
      pre_numbers = (hd issues_numbers([repo_full_path])).numbers
    end

    numbers = issues |> Enum.reduce(pre_numbers, fn(issue, acc) ->
      [issue["number"]|acc] 
    end) |> Enum.uniq() |> Enum.sort()
    issues_numbers = %GithubStalking.Issues{repo_full_path: repo_full_path, numbers: numbers}
    obj = Riak.Object.create(bucket: "issue_numbers", key: repo_full_path, data: Poison.encode!(issues_numbers))
    Riak.put(get_pid, obj)
  end

  def register(repo_full_path, issues) do
    Enum.each(issues, fn(issue) ->
      repo_full_path_with_number = repo_full_path <> "/" <> to_string(issue["number"])
      obj = Riak.Object.create(bucket: "issue_history", key: repo_full_path_with_number, data: Poison.encode!(issue))
      Riak.put(get_pid, obj)
    end)
  end

  @doc"""
  """
  def register(owner, repo, issues) do
    repo_full_path = owner <> "/" <> repo
    register(repo_full_path, issues)
  end

end
