defmodule GithubStalking.Github.IssueNumbers do
  @moduledoc"""
  """

  @derive [Poison.Encoder]
  defstruct [:repo_full_path, :numbers]

  @doc"""
  search issue list from issue_numbers
  """
  def find_issues_numbers(repo_full_path) do
    obj = Riak.find(GithubStalking.Riak.get_pid, "issue_numbers", repo_full_path)

    case obj do
      nil ->
        {:error, []}
      _   ->
        issue_numbers = Poison.decode!(obj.data, as: %GithubStalking.Github.IssueNumbers{})
        {:ok, issue_numbers}
    end
  end

  @doc"""
  """
  def register_issue_numbers(repo_full_path, issues) do
    numbers = issues |> Enum.reduce([], fn(issue, acc) ->
      [issue.number|acc] 
    end) |> Enum.uniq() |> Enum.sort()
    issue_numbers = %GithubStalking.Github.IssueNumbers{repo_full_path: repo_full_path, numbers: numbers}
    obj = Riak.Object.create(bucket: "issue_numbers", key: repo_full_path, data: Poison.encode!(issue_numbers))
    Riak.put(GithubStalking.Riak.get_pid, obj)
  end

  @doc"""
  """
  def register_issue_numbers(owner, repo, issues) do
    repo_full_path = owner <> "/" <> repo
    pre_numbers = []

    prob_pre_issue_numbers = find_issues_numbers(repo_full_path)
    {_, pre_issues} = prob_pre_issue_numbers
    if pre_issues != nil and pre_issues != [] do
      pre_numbers = pre_issues.numbers
    end

    numbers = issues |> Enum.reduce(pre_numbers, fn(issue, acc) ->
      [issue.number|acc] 
    end) |> Enum.uniq() |> Enum.sort()
    issue_numbers_list = %GithubStalking.Github.IssueNumbers{repo_full_path: repo_full_path, numbers: numbers}
    obj = Riak.Object.create(bucket: "issue_numbers", key: repo_full_path, data: Poison.encode!(issue_numbers_list))
    Riak.put(GithubStalking.Riak.get_pid, obj)
  end
end
