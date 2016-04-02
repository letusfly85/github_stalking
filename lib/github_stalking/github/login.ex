defmodule GithubStalking.Github.Login do
  @moduledoc"""
  """
  require Logger

  @derive [Poison.Encoder]
  defstruct [:login, :star_number, :repository_number, :popular_language, :starred_repositories]
end
