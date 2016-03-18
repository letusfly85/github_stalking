defmodule GithubStalking.CommentTest do
  use ExUnit.Case

  test "comment count is 4" do
    comments = GithubStalking.Github.Comment.find_comments("letusfly85/github_stalking_test", 3)

    assert length(comments) == 4
  end
end
