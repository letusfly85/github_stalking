defmodule GithubStalking.UserTest do
  use ExUnit.Case

  alias GithubStalking.Github.User

  setup_all do
    :ok
  end

  test "letusfly85" do
    login = "letusfly85"
    user = User.find(login)
    IO.inspect(user)

    assert user["name"] == "Shunsuke Wada"
  end

end
