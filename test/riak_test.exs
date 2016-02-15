defmodule GithubStalking.RiakTest do
  use ExUnit.Case

  test "can access to riak" do
    issues = [%{"number" => 6}]
    GithubStalking.Riak.register(issues)
    obj = Riak.find(GithubStalking.Riak.get_pid, "issue_history", "letusfly85/github_stalking")
    pre_issue = Poison.decode!(obj.data, as: %GithubStalking.Issue{})

    assert pre_issue.number == 6
  end
end
