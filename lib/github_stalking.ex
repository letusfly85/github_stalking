defmodule GithubStalking do
  @moduledoc"""
  """

  def say_hello() do
    IO.inspect("hello")
  end

  def main(args) do
    IO.inspect("test")
    :timer.sleep(111000)
    {options, _, _} = OptionParser.parse(args,
      switches: [register: :string, collect: :string],
      aliases:  [r: :register,      c: :collect]
    )

    try do
        GithubStalking.Runner.run(options)
    rescue
      e in RuntimeError -> e
        IO.puts e.message
    end
  end
end
