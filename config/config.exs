import Config

config :seedex,
  ecto_repos: [Seedex.Repo],
  repo: Seedex.Repo,
  seeds_path: Path.join(__DIR__, "../test/seeds")

config :seedex, Seedex.Repo,
  database: "seedex_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :logger, level: :info
