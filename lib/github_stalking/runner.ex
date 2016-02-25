defmodule GithubStalking.Runner do
  def run(options) do
    case options do
      %{:register => repo_full_path} -> 
        GithubStalking.register_repo(repo_full_path)

      %{:collect => collect} -> 
        #TODO #22
        #GithubStalking.collect_repos_info
        nil
    end
  end
end
