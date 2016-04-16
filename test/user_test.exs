defmodule GithubStalking.UserTest do
  use ExUnit.Case

  alias GithubStalking.Github.User

  setup_all do
    :ok
  end

  test "letusfly85" do
    login = "letusfly85"
    user = User.find(login)

    assert user["name"] == "Shunsuke Wada"
  end

  test "letusfly85 starred" do
    login = "letusfly85"
    repos = User.starred_urls(login)

    assert length(repos) == 30
  end

end
