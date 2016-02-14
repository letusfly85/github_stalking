defmodule GithubStalking.IssueSpecifierTest do
  use ExUnit.Case

  test "issue 1 should be updated after 2016-02-13T01:05:18Z" do
    pre_issues = %{1 => %{"number" =>  1, "updated_at" => "2016-02-13T01:05:18Z"}} 
    issues = GithubStalking.IssueSpecifier.updated_open_issues("letusfly85", "github_stalking", pre_issues)

    assert length(issues) == 1
    assert hd(issues)["title"] == "[module]search issue list from a github repository"
  end
end
