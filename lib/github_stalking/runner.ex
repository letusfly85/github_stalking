defmodule GithubStalking.Runner do
  def run(options) do
    case options do
      %{:register => repo_full_path, :collect => nil} -> 
        GithubStalking.Repository.register_repo(repo_full_path)

      %{:register => nil, :collect => collect} -> 
        GithubStalking.IssueSpecifier.collect_repos_info
    end
  end
end
