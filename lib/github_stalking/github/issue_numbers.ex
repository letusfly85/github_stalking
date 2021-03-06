defmodule GithubStalking.Github.IssueNumbers do
  @moduledoc"""
  """

  alias GithubStalking.Github.IssueNumbers

  @derive [Poison.Encoder]
  defstruct [:repo_full_path, :numbers]

  @doc"""
  search issue list from issue_numbers
  """
  def find_issues_numbers(repo_full_path) do
    obj = Riak.find("issue_numbers", repo_full_path)

    case obj do
      nil ->
        {:error, []}
      _   ->
        issue_numbers = Poison.decode!(obj.data, as: %IssueNumbers{})
        {:ok, issue_numbers}
    end
  end

  @doc"""
  """
  def register_issue_numbers(repo_full_path, issues) do
    numbers = issues |> Enum.reduce([], fn(issue, acc) ->
      [issue.number|acc] 
    end) |> Enum.uniq() |> Enum.sort()
    issue_numbers = %IssueNumbers{repo_full_path: repo_full_path, numbers: numbers}
    obj = Riak.Object.create(bucket: "issue_numbers", key: repo_full_path, data: Poison.encode!(issue_numbers))
    Riak.put(obj)
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
    issue_numbers_list = %IssueNumbers{repo_full_path: repo_full_path, numbers: numbers}
    obj = Riak.Object.create(bucket: "issue_numbers", key: repo_full_path, data: Poison.encode!(issue_numbers_list))
    Riak.put(obj)
  end
end
