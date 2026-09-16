import Config

config :seedex,
  ecto_repos: [Seedex.Repo],
  repo: Seedex.Repo,
  seeds_path: Path.join(__DIR__, "../test/seeds")

config :seedex, Seedex.Repo,
  database: "seedex_test",
  username: "postgres",
  password: System.get_env("PGPASSWORD", "postgres"),
  hostname: System.get_env("PGHOST", "localhost"),
  port: String.to_integer(System.get_env("PGPORT", "5432")),
  pool: Ecto.Adapters.SQL.Sandbox

config :logger, level: :info
