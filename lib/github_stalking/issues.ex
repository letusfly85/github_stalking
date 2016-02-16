defmodule GithubStalking.Issues do
  @derive [Poison.Encoder]
  defstruct [:repo_full_path, :numbers]
end
