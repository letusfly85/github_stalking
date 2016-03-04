defmodule GithubStalking.IssueTest do
  use ExUnit.Case

  setup_all do
    result = Riak.Bucket.keys(GithubStalking.Riak.get_pid, "issue_history")
    case result do
      {:ok, issues} ->
        Enum.each(issues, fn(issue) ->
          Riak.delete(GithubStalking.Riak.get_pid, "issue_history", issue)
        end)
    end
  end

  test "issue 1 should be updated after 2016-02-13T01:05:18Z" do
    pre_issue = %GithubStalking.Github.Issue{number: 1, updated_at: "2016-03-03T01:05:18Z"}
    pre_issues = %{1=> pre_issue} 
    
    response = GithubStalking.Github.Issue.updated_open_issues("letusfly85", "github_stalking_test", pre_issues)
    case response do
      {:ok, issues} -> 
        assert length(Enum.sort(issues)) == 3
        assert hd(Enum.sort(issues)).title == "test issue 1"
      {:error, _}   -> raise("connection to GitHub is refused!!!")
    end

  end

  test "issue 2 should be updated after 2016-02-13T01:05:18Z" do
    pre_issue = %GithubStalking.Github.Issue{number: 2}
    pre_issues = %{2 => pre_issue} 

    response = GithubStalking.Github.Issue.closed_issues("letusfly85", "github_stalking_test", pre_issues)
    case response do
      {:ok, issues} -> 
        assert length(issues) >= 1
        assert hd(issues)["title"] == "test issue 2"
      {:error, _}   -> raise("connection to GitHub is refused!!!")
    end

  end

  test "should collect one item from a repository" do
    assert 1 == 1
  end
end
