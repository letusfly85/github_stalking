defmodule GithubStalking.Github.Comments do
  @moduledoc"""
  """
  require Logger


  @derive [Poison.Encoder]
  defstruct [:number, :comment_counts, :participants, :comments] 


  @doc"""
  """
  def aggregate_comments do
    
  end
end
