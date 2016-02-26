defmodule GithubStalking.Repository do

  @doc"""
  """
  def register_repo(repo_full_path) do
      obj = Riak.find(GithubStalking.Riak.get_pid, "issue_numbers", repo_full_path)

      case obj do
        nil ->
          issues_numbers = %GithubStalking.Issues{repo_full_path: repo_full_path, numbers: []}
          result = Riak.Object.create(bucket: "issue_numbers", key: repo_full_path, data: Poison.encode!(issues_numbers))
          :ok
      
        _ ->
          IO.inspect(repo_full_path <> " is already registered.")
          :error
      end
  end

end
