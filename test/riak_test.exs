defmodule GithubStalking.RiakTest do
  use ExUnit.Case

  test "can access to riak" do
    issues = [%{"number" => 6}]
    GithubStalking.Riak.register(issues, "letusfly85", "github_stalking")
    obj = Riak.find(GithubStalking.Riak.get_pid, "issue_history", "letusfly85/github_stalking/6")
    pre_issue = Poison.decode!(obj.data, as: %GithubStalking.Issue{})

    assert pre_issue.number == 6
  end

  test "" do
    issues = [%{"number" => 11}, %{"number" => 12}, %{"number" => 13}]
    GithubStalking.Riak.register(issues, "letusfly85", "github_stalking")

    repo_full_path = "letusfly85/github_stalking"
    issues_numbers = %GithubStalking.Issues{repo_full_path: repo_full_path, numbers: [11,12,13]}

    list = GithubStalking.Riak.find_pre_issues(issues_numbers)
    |> Enum.reduce([], fn(obj, acc) ->
      issue = Poison.decode!(obj.data, as: %GithubStalking.Issue{})
      [issue.number|acc]
    end)
   
    assert [11, 12, 13] == list
  end

  test "register issue numbers" do
    issues = [%{"number" => 6}, %{"number" => 7}, %{"number" => 8}]
    GithubStalking.Riak.register_numbers(issues, "letusfly85", "github_stalking")
    obj = Riak.find(GithubStalking.Riak.get_pid, "issue_numbers", "letusfly85/github_stalking")
    issues_numbers = Poison.decode!(obj.data, as: %GithubStalking.Issues{})
    assert [8, 7, 6] == issues_numbers.numbers
  end
end
