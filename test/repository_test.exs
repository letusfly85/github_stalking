defmodule GithubStalking.RepositoryTest do
  use ExUnit.Case
  
  setup_all do
    result = Riak.Bucket.keys("issue_numbers")
    case result do
      {:ok, repositories} ->
        Enum.each(repositories, fn(repository) ->
          Riak.delete("issue_numbers", repository)
        end)
    end

    issues = [%GithubStalking.Github.Issue{number: 11},
              %GithubStalking.Github.Issue{number: 12},
              %GithubStalking.Github.Issue{number: 13}]
    GithubStalking.Github.IssueNumbers.register_issue_numbers("letusfly85",  "github_stalking_test", issues)
    GithubStalking.Github.IssueNumbers.register_issue_numbers("letusfly105", "bitbucket_stalking"  , issues)

    :ok
  end

  test "register repo" do
    repo_full_path = "octocat/Spoon-Knife"
    result = GithubStalking.Github.Repository.register_repo(repo_full_path)

    assert :ok == result
    pre_issues_repos = GithubStalking.Github.Repository.target_repos()
    assert Enum.sort(pre_issues_repos) == 
      Enum.sort(["letusfly105/bitbucket_stalking", "letusfly85/github_stalking_test", "octocat/Spoon-Knife"])
  end

  test "register already exists repo" do
    repo_full_path = "letusfly85/github_stalking_test"
    result = GithubStalking.Github.Repository.register_repo(repo_full_path)
    assert :ok == result
  end

end
