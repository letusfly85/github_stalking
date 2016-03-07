[![Build Status](https://travis-ci.org/letusfly85/github_stalking.svg?branch=master)](https://travis-ci.org/letusfly85/github_stalking)    [![Deps Status](https://beta.hexfaktor.org/badge/all/github/letusfly85/github_stalking.svg)](https://beta.hexfaktor.org/github/letusfly85/github_stalking)

# GithubStalking

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add github_stalking to your list of dependencies in `mix.exs`:

        def deps do
          [{:github_stalking, "~> 0.0.1"}]
        end

  2. Ensure github_stalking is started before your application:

        def application do
          [applications: [:github_stalking]]
        end

## Usage

```bash
export quantum_config_path=quantum.exs
export collect_target_path=target_repos.exs

ulimit -n 65536

elixir --detached mix run -e "GithubStalking.run"
```
