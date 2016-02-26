defmodule GithubStalking.RepositoryTest do
  use ExUnit.Case
  
  setup_all do
    Riak.delete(GithubStalking.Riak.get_pid, "issue_numbers", "octocat/Spoon-Knife") 

    :ok
  end

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
