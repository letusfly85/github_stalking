defmodule GithubStalking.CommentTest do
  use ExUnit.Case

  setup_all do
    prob_issues = Riak.Bucket.keys("comments")
    case prob_issues do
      {:ok, issues} ->
        Enum.each(issues, fn(issue) ->
          Riak.delete("comments", issue)
        end)
    end

    comment  = %GithubStalking.Github.Comment{number: 3, id: 1, body: "test", updated_at: "2016-03-03T01:05:18Z"}
    comments = %GithubStalking.Github.Comments{number: 3, comment_counts: 1, participants: 1, comments: [comment]}
    GithubStalking.Github.Comment.register_comments("letusfly85/github_stalking_test/3", comments)

    :ok
  end

  test "comment count is 4" do
    comments = GithubStalking.Github.Comment.find_github_comments("letusfly85/github_stalking_test", 3)

    assert length(comments) == 4
  end

  test "find stored comments in riak database" do
    prob_comments = GithubStalking.Github.Comment.find_stored_comments("letusfly85/github_stalking_test", 3)
    case prob_comments do
      {:ok, comments} ->
        IO.inspect(comments)
        assert length(comments.comments) == 1
      _ -> nil
    end
  end

end
