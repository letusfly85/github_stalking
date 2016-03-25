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
    dup_participants = Enum.map(comments, fn(comment) -> comment.login end)
    participants   = dup_participants |> Enum.uniq |> Enum.sort
    
    %GithubStalking.Github.Comments{number: hd(comments).number, comment_count: comment_count, participants: participants, comments: comments}
  end
end
