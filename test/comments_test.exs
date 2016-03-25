defmodule GithubStalking.CommentsTest do
  use ExUnit.Case

  setup_all do
    :ok
  end

  test "#TODO" do
    comment = %GithubStalking.Github.Comment{avatar_url: "https://avatars.githubusercontent.com/u/1466545?v=3",
      body: "test", id: 200124407, login: "letusfly85", number: 2, updated_at: "2016-03-23T01:56:08Z"}

    assert 1 == 1
  end
end
