defmodule GithubStalking.Github.Repository do
  @moduledoc"""
  """
  require Logger

  @derive [Poison.Encoder]
  defstruct [:id, :owner, :full_name,  :description, :html_url, :stargazers_count, :language,
             :created_at, :updated_at, :pushed_at]

  @doc"""
  repository list you want to stalk
  """
  def target_repos() do
    obj = Riak.Bucket.keys("issue_numbers")
    case obj do
      {:ok, pre_issues_repos} -> pre_issues_repos
      _ -> :error
    end
  end

  @doc"""
  """
  def register_repo(repo_full_path) do
      obj = Riak.find("issue_numbers", repo_full_path)

      case obj do
        nil ->
          issues_numbers = %GithubStalking.Github.IssueNumbers{repo_full_path: repo_full_path, numbers: []}
          result = Riak.Object.create(bucket: "issue_numbers", key: repo_full_path, data: Poison.encode!(issues_numbers))
          Riak.put(result)
          Logger.info(repo_full_path <> " is registered.")
          :ok
      
        _ ->
          Logger.info(repo_full_path <> " is already registered.")
          :ok
      end
  end

end
