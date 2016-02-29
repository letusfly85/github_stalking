defmodule GithubStalking.RepositoryTest do
  use ExUnit.Case
  
  setup_all do
    result = Riak.Bucket.keys(GithubStalking.Riak.get_pid, "issue_numbers")
    case result do
      {:ok, repositories} ->
        Enum.each(repositories, fn(repository) ->
          Riak.delete(GithubStalking.Riak.get_pid, "issue_numbers", repository)
        end)
    end

    issues = [%{"number" => 11}, %{"number" => 12}, %{"number" => 13}]
    GithubStalking.Riak.register_numbers(issues, "letusfly85",  "github_stalking")
    GithubStalking.Riak.register_numbers(issues, "letusfly105", "bitbucket_stalking")

    :ok
  end

  test "register repo" do
    repo_full_path = "octocat/Spoon-Knife"
    result = GithubStalking.Repository.register_repo(repo_full_path)

    assert :ok == result
    pre_issues_repos = GithubStalking.Repository.target_repos()
    assert Enum.sort(pre_issues_repos) == 
      Enum.sort(["letusfly105/bitbucket_stalking", "letusfly85/github_stalking", "octocat/Spoon-Knife"])
  end

  test "register already exists repo" do
    repo_full_path = "letusfly85/github_stalking"
    result = GithubStalking.Repository.register_repo(repo_full_path)
    assert :error == result
  end

end
