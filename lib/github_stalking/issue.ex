defmodule GithubStalking.Issue do
  @derive [Poison.Encoder]
  defstruct [:number, :title, :updated_at, :owner, :repo]
end
