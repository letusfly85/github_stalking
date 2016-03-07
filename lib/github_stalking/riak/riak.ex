defmodule GithubStalking.Riak do
  @moduledoc"""
  """
  require Logger

  @doc"""
  pid for riak connection
  """
  def get_pid do
    conn = Riak.Connection.start('127.0.0.1', 8087)    

    case conn do
      {:ok, pid} ->
        pid

      {:error, {:tcp, :econnrefused}} ->
        raise "cannot get connection of riak"

      {:error, {:tcp, :emfile}} ->
        raise "cannot get connection of riak"
    end
  end


end
