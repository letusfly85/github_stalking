defmodule GithubStalking.RepositoryTest do
  use ExUnit.Case
  
  test "register repo" do
    repo_full_path = "octocat/Spoon-Knife"
    result = GithubStalking.Repository.register_repo(repo_full_path)
    assert :ok == result
  end

  test "register already exists repo" do
    repo_full_path = "letusfly85/github_stalking"
    result = GithubStalking.Repository.register_repo(repo_full_path)
    assert :error == result
  end
end
