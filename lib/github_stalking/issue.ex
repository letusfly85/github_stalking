defmodule GithubStalking.Issue do
  @derive [Poison.Encoder]
  defstruct [:number, :title]
end
