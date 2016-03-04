defmodule GithubStalking.Github.IssueNumbers do
  @moduledoc"""
  """

  @derive [Poison.Encoder]
  defstruct [:repo_full_path, :numbers]

  @doc"""
  search issue list from issue_numbers
  """
  def find_issues_numbers(repo_full_path_list) do
    repo_full_path_list |> Enum.reduce([], fn(repo_full_path, acc) ->
      obj = Riak.find(GithubStalking.Riak.get_pid, "issue_numbers", repo_full_path)

      case obj do
        nil -> acc
        _   ->
          result = Poison.decode!(obj.data, as: %GithubStalking.Github.IssueNumbers{})
          [result|acc]
      end
    end)
  end

  @doc"""
  """
  def register_issue_numbers(repo_full_path, issues) do
    numbers = issues |> Enum.reduce([], fn(issue, acc) ->
      [issue.number|acc] 
    end) |> Enum.uniq() |> Enum.sort()
    issue_numbers_list = %GithubStalking.Github.IssueNumbers{repo_full_path: repo_full_path, numbers: numbers}
    obj = Riak.Object.create(bucket: "issue_numbers", key: repo_full_path, data: Poison.encode!(issue_numbers_list))
    Riak.put(GithubStalking.Riak.get_pid, obj)
  end

  @doc"""
  """
  def register_issue_numbers(owner, repo, issues) do
    repo_full_path = owner <> "/" <> repo
    pre_numbers = []
    pre_issues = find_issues_numbers([repo_full_path])
    if pre_issues != nil and pre_issues != [] do
      pre_numbers = (hd pre_issues).numbers
    end

    numbers = issues |> Enum.reduce(pre_numbers, fn(issue, acc) ->
      [issue.number|acc] 
    end) |> Enum.uniq() |> Enum.sort()
    issue_numbers_list = %GithubStalking.Github.IssueNumbers{repo_full_path: repo_full_path, numbers: numbers}
    obj = Riak.Object.create(bucket: "issue_numbers", key: repo_full_path, data: Poison.encode!(issue_numbers_list))
    Riak.put(GithubStalking.Riak.get_pid, obj)
  end
end
