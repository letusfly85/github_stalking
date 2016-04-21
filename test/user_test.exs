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

  test "donny-dont's starred python repo is his own one" do
    login = "donny-dont"
    repos = User.starred_urls(login)
    summary_repos = User.summary_repos_by_language(repos)

    assert summary_repos["Python"] == ["donny-dont/Django-Game-Analytics-Example"]
  end

  test "donny-dont's most starred favarite repository is " do
    login = "donny-dont"
    repos = User.starred_urls(login)

    most_starred_repo = hd User.sort_repos_by_star_counts(repos)

    assert most_starred_repo.full_name        == "dart-lang/bleeding_edge-DEPRECATED-USE-SDK-INSTEAD"
    assert most_starred_repo.stargazers_count == 222
    assert most_starred_repo.language         == "Dart"
  end
end
