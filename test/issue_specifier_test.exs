defmodule GithubStalking.IssueSpecifierTest do
  use ExUnit.Case

  test "issue 1 should be updated after 2016-02-13T01:05:18Z" do
    pre_issue = %GithubStalking.Issue{number: 1, updated_at: "2016-02-13T01:05:18Z"}
    pre_issues = %{1 => pre_issue} 
    
    issues = GithubStalking.IssueSpecifier.updated_open_issues("letusfly85", "github_stalking", pre_issues)

    assert length(issues) == 1
    assert hd(issues)["title"] == "[module]search issue list from a github repository"
  end

  test "issue 6 should be updated after 2016-02-13T01:05:18Z" do
    #pre_issues = %{6 => Factory.attributes_for(:issue, number: 6) |> Factory.parametrize} 
    pre_issue = %GithubStalking.Issue{number: 6}
    pre_issues = %{6 => pre_issue} 
    issues = GithubStalking.IssueSpecifier.closed_issues("letusfly85", "github_stalking", pre_issues)

    assert length(issues) >= 1
    assert hd(issues)["title"] == "[module]search still open and updated issue list from a github repository"
  end
end
