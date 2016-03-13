defmodule GithubStalking.Github.Comment do
  @moduledoc"""
  """
  require Logger

  @client Tentacat.Client.new(System.get_env("access_token"))

  @derive [Poison.Encoder]
  defstruct [:number, :id, :updated_at, :avatar_url]

end
  
