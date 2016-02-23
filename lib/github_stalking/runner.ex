defmodule GithubStalking.Runner do
  def run(options) do
    %{:register => repo_full_path, :collect => collect} = options

    if repo_full_path != nil do
      #TODO #22
      #GithubStalking.register_repo(repo_full_path)
      nil

    else
      #TODO #22
      #GithubStalking.collect_repos_info
      nil
    end

  end
end
