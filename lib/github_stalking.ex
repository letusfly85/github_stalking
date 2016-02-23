defmodule GithubStalking do
  def main(args) do
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
