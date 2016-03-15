defmodule GithubStalking.Github.Comment do
  @moduledoc"""
  """
  require Logger

  @client Tentacat.Client.new(System.get_env("access_token"))

  @derive [Poison.Encoder]
  defstruct [:number, :id, :updated_at, :avatar_url, :login]


  @doc"""
  """
  def find_comments(repo_full_path) do
    ary = String.split(repo_full_path, "/")
    owner = Enum.at(ary, 0)
    repo  = Enum.at(ary, 1)
    
    Tentacat.Issues.Comments.list(owner, repo, @client)
  end

  @doc"""
  """
  def find_new_comments(new_comments, old_comments) do
    target_list = Map.to_list(new_comments)
    Enum.reduce(target_list, [], fn(new_comment_map, acc) ->
      new_comment_id  = hd Map.keys(new_comment_map)
      new_comment     = new_comment_map[new_comment_id]

      case new_comment == old_comments[new_comment_id] do
        true -> acc
        _    -> [new_comment|acc]
      end
    end)
  end
end
