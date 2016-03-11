# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :github_stalking, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:github_stalking, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

#TODO if issue was clear, use this
#config :remix,
#  escript: true,
#  silent: true
#  test: true

config :logger,
  backends: [{LoggerFileBackend, :info},
             {LoggerFileBackend, :error}]

config :logger, :info,
  path: "/var/log/tools/github_stalking.log",
  level: :info

config :logger, :error,
  path: "/var/log/tools/github_stalking_err.log",
  level: :error

import_config "#{System.get_env("quantum_config_path")}"
import_config "#{System.get_env("collect_target_path")}"

import_config("#{Mix.env}.exs")

config :pooler, pools:
  [
    [
      name: :riaklocal,
      group: :riak,
      max_count: 15,
      init_count: 2,
      start_mfa: { Riak.Connection, :start_link, ['127.0.0.1', 8087] }
    ]
  ]

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
