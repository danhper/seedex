use Mix.Config

config :seedex,
  ecto_repos: [Seedex.Repo],
  repo: Seedex.Repo,
  seeds_path: Path.join(__DIR__, "../test/seeds")

config :seedex, Seedex.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "seedex_test",
  username: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :logger, level: :info
