defmodule GithubStalking.RiakTest do
  use ExUnit.Case

  test "get repos from issue_numbers" do
    issues = [%{"number" => 11}, %{"number" => 12}, %{"number" => 13}]
    GithubStalking.Riak.register_numbers(issues, "letusfly85",  "github_stalking")
    GithubStalking.Riak.register_numbers(issues, "letusfly105", "bitbucket_stalking")

    pre_issues_repos = GithubStalking.Riak.find_pre_issues_repos()
    assert Enum.sort(pre_issues_repos) == Enum.sort(["letusfly105/bitbucket_stalking", "letusfly85/github_stalking"])
  end

  test "get issue numbers from issue_numbers" do
    issues = [%{"number" => 11}, %{"number" => 12}, %{"number" => 13}]
    GithubStalking.Riak.register_numbers(issues, "letusfly85",  "github_stalking")

    issue_numbers = GithubStalking.Riak.issues_numbers(["letusfly85/github_stalking"])
    assert (hd issue_numbers).numbers == [13, 12, 11]
    assert (hd issue_numbers).repo_full_path == "letusfly85/github_stalking"
  end

  test "get pre issues from issue_numbers" do
    issues = [%{"number" => 14}, %{"number" => 15}, %{"number" => 16}]
    GithubStalking.Riak.register_numbers(issues, "letusfly85",  "github_stalking")
    GithubStalking.Riak.register(issues, "letusfly85", "github_stalking")

    issue_numbers = %GithubStalking.Issues{repo_full_path: "letusfly85/github_stalking", numbers: [14, 15, 16]}
    pre_issues = GithubStalking.Riak.find_pre_issues(issue_numbers)
    assert length(pre_issues) == 3
  end

  test "get pre issues number map from issue_numbers" do
    issues = [%{"number" => 14}, %{"number" => 15}, %{"number" => 16}]
    GithubStalking.Riak.register_numbers(issues, "letusfly85",  "github_stalking")
    GithubStalking.Riak.register(issues, "letusfly85", "github_stalking")

    issue_numbers = %GithubStalking.Issues{repo_full_path: "letusfly85/github_stalking", numbers: [14, 15, 16]}
    pre_issues = GithubStalking.Riak.find_pre_issues_map(issue_numbers)

    assert pre_issues[14].number == 14
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

    list = GithubStalking.Riak.find_pre_issues(issues_numbers)
    |> Enum.reduce([], fn(issue, acc) ->
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
