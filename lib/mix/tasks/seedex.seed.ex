defmodule Mix.Tasks.Seedex.Seed do
  use Mix.Task

  @shortdoc "Mix task to populate database with seed data"
  @moduledoc """
  Mix task to populate database with seed data

  The task will load all the files under `seeds_path` and `seeds_path/MIX_ENV` if it exists,
  and will run them sequentially in alphabetic order, regardless of which directory they come from.

  ## Options

    * `--debug`      - Enable debug logs
    * `--quiet`      - Disable all logs
    * `--env`        - Override `MIX_ENV`. Useful to add production seeds in staging env.
    * `--seeds-path` - Override the settings with the same name from mix config, defaults to `priv/repo/seeds`

  ## Examples

      mix seedex.seed
      mix seedex.seed --seeds-path=path/to/seeds --quiet
      mix seedex.seed --seeds-path=path/to/seeds --env=staging
  """

  @doc false
  def run(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        switches: [env: :string, seeds_path: :string, debug: :boolean, quiet: :boolean]
      )

    if opts[:debug] do
      Logger.configure(level: :debug)
    else
      Logger.configure(level: :info)
    end

    Mix.Task.run("app.start", [])

    seeds_path = Keyword.get(opts, :seeds_path, default_path())
    env = Keyword.get(opts, :env, to_string(Mix.env()))

    unless File.dir?(seeds_path) do
      Mix.raise("""
      seeeds_path is not a directory, create priv/repo/seeds or configure in :seedex configuration
      """)
    end

    seeds_path
    |> seeds_files(env)
    |> Enum.each(&Code.compile_file(&1))

    unless opts[:quiet] do
      Mix.shell().info("Database has been populated with seeds from #{seeds_path}")
    end
  end

  defp seeds_files(path, env) do
    files = exs_files(path) ++ exs_files(Path.join(path, env))
    Enum.sort(files)
  end

  defp exs_files(path) do
    path
    |> Path.join("*.exs")
    |> Path.wildcard()
  end

  defp default_path do
    Application.get_env(:seedex, :seeds_path, "priv/repo/seeds")
  end
end
