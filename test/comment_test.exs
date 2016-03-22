defmodule GithubStalking.CommentTest do
  use ExUnit.Case

  setup_all do
    #TODO create comment objects to a riak database.

    :ok
  end

  test "comment count is 4" do
    comments = GithubStalking.Github.Comment.find_github_comments("letusfly85/github_stalking_test", 3)

    assert length(comments) == 4
  end

  test "find stored comments in riak database" do
    #TODO
    comments = GithubStalking.Github.Comment.find_stored_comments("letusfly85/github_stalking_test", 3)
    IO.inspect(comments)

    assert 1 == 1
  end
end
