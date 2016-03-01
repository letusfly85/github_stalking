defmodule GithubStalking.Issues do
  @moduledoc"""
  """

  @derive [Poison.Encoder]
  defstruct [:repo_full_path, :numbers]
end
