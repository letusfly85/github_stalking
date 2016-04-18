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

  test "octocat starred" do
    login = "octocat"
    repos = User.starred_urls(login)

    assert length(repos) == 2
    
    repo = Enum.at(repos, 0)

    assert repo.id        == 1296269
    assert repo.owner     == "octocat"
    assert repo.full_name == "octocat/Hello-World"
  end

end
