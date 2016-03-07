defmodule GithubStalking.Mixfile do
  use Mix.Project

  def project do
    [app: :github_stalking,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     escript: escript,
     deps: deps]
  end

  def escript do
    [main_module: GithubStalking]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: applications(Mix.env)]
  end

  #TODO
  #defp applications(:dev), do: applications(:all) ++ [:remix]
  #defp applications(:test), do: applications(:all) ++ [:remix]
  defp applications(:test), do: applications(:all) ++ [:factory_girl_elixir]
  defp applications(_all), do: [:logger, :tentacat, :riak, :quantum]

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [#{:remix, "~> 0.0.1", only: [:dev, :test]},
     #{:remix, git: "https://github.com/letusfly85/remix.git", only: [:dev, :test]},
     {:mix_test_watch, "~> 0.2", only: :dev},
     {:tentacat, "~> 0.2"},
     {:riak, "~> 1.0"},
     {:poison, "~> 2.0"},
     {:quantum, ">= 1.6.1"},
     {:factory_girl_elixir, "~> 0.1.1"},
     {:credo, "~> 0.3", only: [:dev, :test]},
     {:logger_file_backend, "~> 0.0.6"}
    ]
  end
end
