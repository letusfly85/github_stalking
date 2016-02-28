defmodule GithubStalking.RepositoryTest do
  use ExUnit.Case
  
  setup_all do
    issues = [%{"number" => 11}, %{"number" => 12}, %{"number" => 13}]
    GithubStalking.Riak.register_numbers(issues, "letusfly85",  "github_stalking")
    GithubStalking.Riak.register_numbers(issues, "letusfly105", "bitbucket_stalking")

    Riak.delete(GithubStalking.Riak.get_pid, "issue_numbers", "octocat/Spoon-Knife") 

    :ok
  end

  test "get repos from issue_numbers" do
    pre_issues_repos = GithubStalking.Repository.target_repos()
    assert Enum.sort(pre_issues_repos) == 
      Enum.sort(["letusfly105/bitbucket_stalking", "letusfly85/github_stalking", "octocat/Spoon-Knife"])
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
