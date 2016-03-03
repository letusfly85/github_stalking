defmodule GithubStalking.IssueNumbersTest do
  use ExUnit.Case

  setup_all do
    result = Riak.Bucket.keys(GithubStalking.Riak.get_pid, "issue_history")
    case result do
      {:ok, issues} ->
        Enum.each(issues, fn(issue) ->
          Riak.delete(GithubStalking.Riak.get_pid, "issue_history", issue)
        end)
    end
    result = Riak.Bucket.keys(GithubStalking.Riak.get_pid, "issue_numbers")
    case result do
      {:ok, repositories} ->
        Enum.each(repositories, fn(repository) ->
          Riak.delete(GithubStalking.Riak.get_pid, "issue_numbers", repository)
        end)
    end

    issues = Enum.to_list 1..3
    |> Enum.reduce([], fn(elem, acc) ->
      issue = Factory.attributes_for(:issue, number: elem) |> Factory.parametrize
      [issue|acc]
    end)
    GithubStalking.Github.IssueNumbers.register_issue_numbers("letusfly85",  "github_stalking_test", issues)
    GithubStalking.Github.Issue.register_issues("letusfly85", "github_stalking_test", issues)

    issues2 = [%{"number" => 1}, %{"number" => 2}, %{"number" => 3}]
    GithubStalking.Github.IssueNumbers.register_issue_numbers("letusfly85",  "github_stalking_test", issues2)
    GithubStalking.Github.IssueNumbers.register_issue_numbers("letusfly105", "bitbucket_stalking",   issues2)

    :ok
  end

  test "get issue numbers from issue_numbers" do
    issue_numbers = GithubStalking.Github.IssueNumbers.find_issues_numbers(["letusfly85/github_stalking_test"])
    assert (hd issue_numbers).numbers == Enum.to_list 1..3
    assert (hd issue_numbers).repo_full_path == "letusfly85/github_stalking_test"
  end

  test "get pre issues from issue_numbers" do
    issue_numbers = %GithubStalking.Github.IssueNumbers{repo_full_path: "letusfly85/github_stalking_test", numbers: [1, 2, 3]}
    pre_issues = GithubStalking.Github.Issue.find_pre_issues(issue_numbers)
    assert length(pre_issues) == 3
  end

  test "get pre issues number map from issue_numbers" do
    issue_numbers = %GithubStalking.Github.IssueNumbers{repo_full_path: "letusfly85/github_stalking_test", numbers: [1, 2, 3]}
    pre_issues = GithubStalking.Github.Issue.find_pre_issues_map(issue_numbers)

    assert pre_issues[1].number == 1
  end

  test "get unique issue from issue_history" do
    obj = Riak.find(GithubStalking.Riak.get_pid, "issue_history", "letusfly85/github_stalking_test/1")
    pre_issue = Poison.decode!(obj.data, as: %GithubStalking.Github.Issue{})

    assert pre_issue.number == 1
  end

  test "get issue numbers of a repository from issue_numbers" do
    repo_full_path = "letusfly85/github_stalking_test"
    issues_numbers = %GithubStalking.Github.IssueNumbers{repo_full_path: repo_full_path, numbers: [1, 2, 3]}

    list = GithubStalking.Github.Issue.find_pre_issues(issues_numbers)
    |> Enum.reduce([], fn(issue, acc) ->
      [issue.number|acc]
    end)
   
    assert [1, 2, 3] == list
  end

  test "register issue numbers" do
    issues = [%{"number" => 1}, %{"number" => 2}, %{"number" => 3}]
    GithubStalking.Github.IssueNumbers.register_issue_numbers("letusfly85", "github_stalking_test", issues)
    obj = Riak.find(GithubStalking.Riak.get_pid, "issue_numbers", "letusfly85/github_stalking_test")
    issues_numbers = Poison.decode!(obj.data, as: %GithubStalking.Github.IssueNumbers{})
    assert issues_numbers.numbers == Enum.to_list 1..3
  end

end
