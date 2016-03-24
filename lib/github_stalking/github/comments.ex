defmodule GithubStalking.Github.Comments do
  @moduledoc"""
  """
  require Logger


  @derive [Poison.Encoder]
  defstruct [:number, :comment_count, :participants, :comments] 


  @doc"""
  """
  def aggregate_comments(comments) do
    comment_count = length(comments)
    participants   = Enum.unique(Enum.map(comments, fn(comment) -> comment.login end))
    
    %GithubStalking.Github.Comments{number: hd(comments).number, comment_count: comment_count, participants: participants, comments: comments}
  end
end
