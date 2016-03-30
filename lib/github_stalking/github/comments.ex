defmodule GithubStalking.Github.Comments do
  @moduledoc"""
  """
  require Logger


  @derive [Poison.Encoder]
  defstruct [:number, :comments, :comment_count, :participants, :participant_count] 


  @doc"""
  """
  def aggregate_comments(number, comments) do
      comment_count = length(comments)
      dup_participants = Enum.map(comments, fn(comment) -> comment.login end)
      participants   = dup_participants |> Enum.uniq |> Enum.sort
      
      %GithubStalking.Github.Comments{number: number, 
                                      comments: comments,         comment_count: comment_count, 
                                      participants: participants, participant_count:  length(participants)}

  end
end
