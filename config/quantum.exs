use Mix.Config

config :quantum, cron: [
    # Every minute
    "* * * * *": {GithubStalking, :auto_collect3}
]
