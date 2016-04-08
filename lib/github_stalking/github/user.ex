defmodule GithubStalking.Github.User do
  @moduledoc"""
  """
  require Logger
    
  @client Tentacat.Client.new(%{access_token: System.get_env("access_token")})

  @derive [Poison.Encoder]
  defstruct [:login, :star_number, :repository_number, :popular_language, :starred_repositories]

  @doc"""
  """
  def find(login) do
    Tentacat.Users.find(login, @client)
  end
end
