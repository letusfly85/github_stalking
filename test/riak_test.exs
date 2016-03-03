defmodule GithubStalking.RiakTest do
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

    issues = Enum.to_list 6..16
    |> Enum.reduce([], fn(elem, acc) ->
      issue = Factory.attributes_for(:issue, number: elem) |> Factory.parametrize
      [issue|acc]
    end)
    GithubStalking.Riak.register_numbers(issues, "letusfly85",  "github_stalking")
    GithubStalking.Riak.register("letusfly85", "github_stalking", issues)

    issues2 = [%{"number" => 11}, %{"number" => 12}, %{"number" => 13}]
    GithubStalking.Riak.register_numbers(issues2, "letusfly85",  "github_stalking")
    GithubStalking.Riak.register_numbers(issues2, "letusfly105", "bitbucket_stalking")

    :ok
  end


  test "get issue numbers from issue_numbers" do
    issue_numbers = GithubStalking.Riak.issues_numbers(["letusfly85/github_stalking"])
    assert (hd issue_numbers).numbers == Enum.to_list 6..16
    assert (hd issue_numbers).repo_full_path == "letusfly85/github_stalking"
  end

  test "get pre issues from issue_numbers" do
    issue_numbers = %GithubStalking.Issues{repo_full_path: "letusfly85/github_stalking", numbers: [14, 15, 16]}
    pre_issues = GithubStalking.Riak.find_pre_issues(issue_numbers)
    assert length(pre_issues) == 3
  end

  test "get pre issues number map from issue_numbers" do
    issue_numbers = %GithubStalking.Issues{repo_full_path: "letusfly85/github_stalking", numbers: [14, 15, 16]}
    pre_issues = GithubStalking.Riak.find_pre_issues_map(issue_numbers)

    assert pre_issues[14].number == 14
  end

  test "get unique issue from issue_history" do
    obj = Riak.find(GithubStalking.Riak.get_pid, "issue_history", "letusfly85/github_stalking/11")
    pre_issue = Poison.decode!(obj.data, as: %GithubStalking.Issue{})

    assert pre_issue.number == 11
  end

  test "get issue numbers of a repository from issue_numbers" do
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
    assert issues_numbers.numbers == Enum.to_list 6..16
  end

end
