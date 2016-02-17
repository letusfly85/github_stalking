defmodule GithubStalking.RiakTest do
  use ExUnit.Case

  #GithubStalking.Riak.register(issues, "letusfly85", "github_stalking")
  #GithubStalking.Riak.register_numbers(issues, "letusfly85",  "github_stalking")
  #GithubStalking.Riak.register_numbers(issues, "letusfly105", "bitbucket_stalking")
  test "get repos from issue_numbers" do
    issues = [%{"number" => 11}, %{"number" => 12}, %{"number" => 13}]
    GithubStalking.Riak.register_numbers(issues, "letusfly85",  "github_stalking")
    GithubStalking.Riak.register_numbers(issues, "letusfly105", "bitbucket_stalking")

    pre_issues_repos = GithubStalking.Riak.find_pre_issues_repos()
    assert pre_issues_repos == ["letusfly105/bitbucket_stalking", "letusfly85/github_stalking"]
  end

  test "get unique issue from issue_history" do
    issues = [%{"number" => 6}]
    GithubStalking.Riak.register(issues, "letusfly85", "github_stalking")
    obj = Riak.find(GithubStalking.Riak.get_pid, "issue_history", "letusfly85/github_stalking/6")
    pre_issue = Poison.decode!(obj.data, as: %GithubStalking.Issue{})

    assert pre_issue.number == 6
  end

  test "get issue numbers of a repository from issue_numbers" do
    issues = [%{"number" => 11}, %{"number" => 12}, %{"number" => 13}]
    GithubStalking.Riak.register(issues, "letusfly85", "github_stalking")

    repo_full_path = "letusfly85/github_stalking"
    issues_numbers = %GithubStalking.Issues{repo_full_path: repo_full_path, numbers: [11,12,13]}

    list = GithubStalking.Riak.find_pre_issues_numbers(issues_numbers)
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
