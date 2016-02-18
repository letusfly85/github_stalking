defmodule GithubStalking do
  def main(args) do
    Enum.each(args, fn(arg) ->
      IO.inspect(arg)
    end)
  end
end

defmodule GithubStalking.CLI do
  def main(args) do
    IO.puts "#TODO github stalking"
  end
end
