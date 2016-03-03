defmodule GithubStalking.IssueSpecifierTest do
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
    pre_issue = %GithubStalking.Issue{number: 22, updated_at: "2016-02-13T01:05:18Z"}
    pre_issues = %{22 => pre_issue} 
    
    response = GithubStalking.IssueSpecifier.updated_open_issues("letusfly85", "github_stalking", pre_issues)
    case response do
      {:ok, issues} -> 
        assert length(Enum.sort(issues)) == 6
        assert hd(Enum.sort(issues))["title"] == "notify to slack"
      {:error, _}   -> raise("connection to GitHub is refused!!!")
    end

  end

  test "issue 6 should be updated after 2016-02-13T01:05:18Z" do
    pre_issue = %GithubStalking.Issue{number: 6}
    pre_issues = %{6 => pre_issue} 

    response = GithubStalking.IssueSpecifier.closed_issues("letusfly85", "github_stalking", pre_issues)
    case response do
      {:ok, issues} -> 
        assert length(issues) >= 1
        IO.inspect(issues)
        assert hd(issues)["title"] == "[module]search still open and updated issue list from a github repository"
      {:error, _}   -> raise("connection to GitHub is refused!!!")
    end

  end

  test "should collect one item from a repository" do
    assert 1 == 1
  end
end
