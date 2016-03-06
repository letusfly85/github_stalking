use Mix.Config

config :quantum, cron: [
    # Every minute
    "* * * * *": {GithubStalking, :say_hello}
]
