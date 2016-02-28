defmodule GithubStalking.Repository do

  @doc"""
  repository list you want to stalk
  """
  def target_repos() do
    {:ok, pre_issues_repos} = Riak.Bucket.keys(GithubStalking.Riak.get_pid, "issue_numbers")
    pre_issues_repos
  end

  @doc"""
  """
  def register_repo(repo_full_path) do
      obj = Riak.find(GithubStalking.Riak.get_pid, "issue_numbers", repo_full_path)

      case obj do
        nil ->
          issues_numbers = %GithubStalking.Issues{repo_full_path: repo_full_path, numbers: []}
          result = Riak.Object.create(bucket: "issue_numbers", key: repo_full_path, data: Poison.encode!(issues_numbers))
          Riak.put(GithubStalking.Riak.get_pid, result)
          IO.inspect(repo_full_path <> " is registered.")
          :ok
      
        _ ->
          IO.inspect(repo_full_path <> " is already registered.")
          :error
      end
  end

end
