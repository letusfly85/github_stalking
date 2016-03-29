defmodule GithubStalking.CommentsTest do
  use ExUnit.Case

  setup_all do
    :ok
  end

  test "aggregate comment of a issue" do
    issue_number = 2
    comment_1 = %GithubStalking.Github.Comment{avatar_url: "https://avatars.githubusercontent.com/u/1466545?v=3",
      body: "test", id: 200124407, login: "letusfly85", number: issue_number,  updated_at: "2016-03-23T01:56:08Z"}
    comment_2 = %GithubStalking.Github.Comment{avatar_url: "https://avatars.githubusercontent.com/u/1466545?v=3",
      body: "test", id: 200124409, login: "jellyfish85", number: issue_number, updated_at: "2016-03-23T01:56:08Z"}

    comments = GithubStalking.Github.Comments.aggregate_comments(issue_number, [comment_1, comment_2])

    assert comments.participants  == ["jellyfish85", "letusfly85"]
    assert comments.comment_count == 2
    assert comments.number        == 2
  end
end
