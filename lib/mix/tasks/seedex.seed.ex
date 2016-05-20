defmodule Mix.Tasks.Seedex.Seed do
  use Mix.Task

  @shortdoc "Mix task to populate database with seed data"
  @moduledoc """
  Mix task to populate database with seed data

  ## Options

    * `--debug`      - Enable debug logs
    * `--env`        - Override `MIX_ENV`. Useful to add production seeds in staging env.
    * `--seeds-path` - Override the settings with the same name from mix config, defaults to `priv/seeds`

  ## Examples

      mix seedex.seed
      mix seedex.seed --seeds-path=path/to/seeds --quiet
      mix seedex.seed --seeds-path=path/to/seeds --env=staging
  """

  @doc false
  def run(args) do
    {opts, _, _} = OptionParser.parse(args, switches: [env: :string, seeds_path: :string, verbose: :boolean])
    if opts[:verbose] do
      Logger.configure(level: :debug)
    end

    seeds_path = Keyword.get(opts, :seeds_path, default_path)
    env = Keyword.get(opts, :env, to_string(Mix.env))

    unless File.dir?(seeds_path) do
      Mix.raise """
      seeeds_path is not a directory, create priv/seeds or configure in :seedex configuration
      """
    end

    seeds_path
    |> seeds_files(env)
    |> Enum.each(&Code.eval_file(&1))
  end

  defp seeds_files(path, env) do
    files = exs_files(path) ++ exs_files(Path.join(path, env))
    Enum.sort(files)
  end

  defp exs_files(path) do
    path
    |> Path.join("*.exs")
    |> Path.wildcard
  end

  defp default_path do
    Application.get_env(:seedex, :seeds_path, "priv/seeds")
  end
end
