defmodule GithubStalking.Github.Comment do
  @moduledoc"""
  """
  require Logger

  @client Tentacat.Client.new(%{access_token: System.get_env("access_token")})

  @derive [Poison.Encoder]
  defstruct [:number, :id, :body, :updated_at, :avatar_url, :login]

  @doc"""
  find comments from GitHub API using a repository name and its issue number
  """
  def find_github_comments(repo_full_path, number) do
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
  def find_stored_comments(repo_full_path, number) do
    repo_full_path_with_number = repo_full_path <> "/" <> to_string(number)
    obj = Riak.find("comments", repo_full_path_with_number)
    
    case obj do
      nil -> {:error, %{}}
      _   ->
          stored_comments = Poison.decode!(obj.data, as: %GithubStalking.Github.Comments{})
          {:ok, stored_comments}
    end
  end

  @doc"""
  """
  def find_new_comments(new_comments, old_comments) do
    Enum.reduce(new_comments, [], fn(new_comment, acc) ->
      new_comment_id  = new_comment.id
      case new_comment == old_comments[new_comment_id] do
        true -> acc
        _    -> [new_comment|acc]
      end
    end)
  end

  @doc"""
  register comments to riak database
  """
  def register_comments(repo_full_path_with_number, comments) do
    obj = Riak.Object.create(bucket: "comments", key: repo_full_path_with_number, data: Poison.encode!(comments))
    Riak.put(obj)
  end

end
