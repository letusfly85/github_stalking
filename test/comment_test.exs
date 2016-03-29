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
    comments = %GithubStalking.Github.Comments{number: 3, comment_count: 1, participants: 1, comments: [comment]}
    GithubStalking.Github.Comment.register_comments("letusfly85/github_stalking_test/3", comments)

    comment = %GithubStalking.Github.Comment{avatar_url: "https://avatars.githubusercontent.com/u/1466545?v=3",
      body: "test", id: 200124407, login: "letusfly85", number: 4,
        updated_at: "2016-03-23T01:56:08Z"}
    comments = %GithubStalking.Github.Comments{number: 4, comment_count: 1, participants: 1, comments: [comment]}
    GithubStalking.Github.Comment.register_comments("letusfly85/github_stalking_test/4", comments)
    :ok
  end

  test "comment count is 4" do
    {:ok, comments} = GithubStalking.Github.Comment.find_github_comments("letusfly85/github_stalking_test", 3)

    assert length(comments) == 4
  end

  test "find stored comments in riak database" do
    prob_comments = GithubStalking.Github.Comment.find_stored_comments("letusfly85/github_stalking_test", 3)
    case prob_comments do
      {:ok, comments} ->
        assert length(comments.comments) == 1
      _ -> nil
    end
  end

  test "find new comments" do
    prob_current_comments = GithubStalking.Github.Comment.find_github_comments("letusfly85/github_stalking_test", 4)
    prob_stored_comments  = GithubStalking.Github.Comment.find_stored_comments("letusfly85/github_stalking_test", 4)

    new_comments = GithubStalking.Github.Comment.find_new_comments(prob_current_comments, prob_stored_comments)
    
    assert length(new_comments) == 3
  end

  test "no comments issue" do
    prob_current_comments = GithubStalking.Github.Comment.find_github_comments("letusfly85/github_stalking_test", 2)

    case prob_current_comments do
      {:error, comments} -> length(comments) == 0
    end
  end

end
