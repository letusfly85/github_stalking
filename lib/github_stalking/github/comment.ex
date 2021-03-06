defmodule GithubStalking.Github.Comment do
  @moduledoc"""
  """
  require Logger

  alias GithubStalking.Github.Comment
  alias GithubStalking.Github.Comments

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
    comments = Enum.reduce(t_comments, [], fn(t_comment, acc) ->
      n_comment = 
        for {key, _} <- Map.from_struct(Comment.__struct__()), into: %{},
                          do: {key, t_comment[Atom.to_string(key)]}
      comment = struct(Comment, n_comment)
      comment = Map.put(comment, :avatar_url, t_comment["user"]["avatar_url"])
      comment = Map.put(comment, :login,      t_comment["user"]["login"])
      comment = Map.put(comment, :updated_at, t_comment["updated_at"])
      comment = Map.put(comment, :number,     number)
      [comment|acc]
    end)

    case comments do
      [] -> {:error, []}
      _  -> {:ok,    comments}
    end
  end

  @doc"""
  """
  def find_stored_comments(repo_full_path, number) do
    repo_full_path_with_number = repo_full_path <> "/" <> to_string(number)
    obj = Riak.find("comments", repo_full_path_with_number)
    
    case obj do
      nil -> {:ok, %{}}
      _   ->
          stored_comments = Poison.decode!(obj.data, as: %Comments{})
          {:ok, stored_comments}
    end
  end

  @doc"""
  """
  def find_comments(issue) do
    repo_full_path = issue.owner <> "/" <> issue.repo
    prob_stored_comments  = Comment.find_stored_comments(repo_full_path, issue.number)
    prob_current_comments = Comment.find_github_comments(repo_full_path, issue.number)

    new_comments = Comment.find_new_comments(prob_current_comments, prob_stored_comments)

    Comments.aggregate_comments(issue.number, new_comments)
  end

  @doc"""
  """
  def find_new_comments(prob_current_comments, prob_stored_comments) do
    case {prob_current_comments, prob_stored_comments} do
      {{:ok, current_comments}, {:ok, stored_comments}} ->
        gather_comments(current_comments, stored_comments)
      _ ->
        []
    end
  end

  @doc"""
  """
  def gather_comments(current_comments, stored_comments) do
    Logger.info(inspect current_comments)
    Logger.info(inspect stored_comments)
    case stored_comments do
      %{} -> current_comments
      _   ->
        mapped_old_comments = map_id2comments(stored_comments)
        gather_comments_map(current_comments, mapped_old_comments)
    end
  end

  def gather_comments_map(current_comments, mapped_old_comments) do
    Enum.reduce(current_comments, [], fn(new_comment, acc) ->
      new_comment_id  = new_comment.id
      case new_comment == mapped_old_comments[new_comment_id] do
        true -> acc
        _    -> [new_comment|acc]
      end
    end)
  end

  defp map_id2comments(comments) do
    Enum.reduce(comments.comments, %{}, fn(comment, acc) ->
      n_comment = 
        for {key, _} <- Map.from_struct(Comment.__struct__()), into: %{},
                          do: {key, comment[Atom.to_string(key)]}
      s_comment = Map.merge(%Comment{}, n_comment)
      Map.put(acc, comment["id"] ,s_comment)
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
