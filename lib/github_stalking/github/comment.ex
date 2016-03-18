defmodule GithubStalking.Github.Comment do
  @moduledoc"""
  """
  require Logger

  @client Tentacat.Client.new(%{access_token: System.get_env("access_token")})

  @derive [Poison.Encoder]
  defstruct [:number, :id, :body, :updated_at, :avatar_url, :login]

  @doc"""
  """
  def find_comments(repo_full_path, number) do
    ary = String.split(repo_full_path, "/")
    owner = Enum.at(ary, 0)
    repo  = Enum.at(ary, 1)
    
    t_comments = Tentacat.Issues.Comments.list(owner, repo, number, @client)
    Enum.reduce(t_comments, [], fn(t_comment, acc) ->
      n_comment = 
        for {key, _} <- Map.from_struct(GithubStalking.Github.Comment.__struct__()), into: %{},
                          do: {key, t_comment[Atom.to_string(key)]}
      comment = struct(GithubStalking.Github.Comment, n_comment)
      comment = Map.put(comment, :avatar_url, t_comment["user"]["avatar_url"])
      comment = Map.put(comment, :login,      t_comment["user"]["login"])
      comment = Map.put(comment, :number,     number)
      [comment|acc]
    end)
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

  @doc"""
  """
  def aaa do

  end
end
