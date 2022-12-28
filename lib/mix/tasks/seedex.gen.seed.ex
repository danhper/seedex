defmodule Mix.Tasks.Seedex.Gen.Seed do
  use Mix.Task

  import Macro, only: [underscore: 1, camelize: 1]
  import Mix.Generator

  @shortdoc "Mix task to create a new seed"

  @aliases [
    r: :repo
  ]

  @switches [
    seeds_path: :string,
    env: :string,
    repo: [:string, :keep],
  ]

  @impl Mix.Task
  def run(args) do
    {opts, [name], _} = OptionParser.parse(args, switches: @switches, aliases: @aliases)

    Mix.Task.run("app.start", [])

    repo = Mix.Ecto.parse_repo(opts) |> hd
    seeds_path = Keyword.get(opts, :seeds_path, Mix.Tasks.Seedex.Seed.default_path())
    env = Keyword.get(opts, :env)

    path = if env do
      Path.join(seeds_path, env)
    else
      seeds_path
    end

    base_name = "#{underscore(name)}.exs"
    file = Path.join(path, "#{timestamp()}_#{base_name}")
    unless File.dir?(path), do: create_directory path

    fuzzy_search(path, base_name, name)
    fuzzy_search(seeds_path, base_name, name)

    assigns = [mod: Module.concat([repo, Seeds, camelize(name)]), repo: repo]
    create_file file, seed_template(assigns)
  end

  # Taken from ecto.gen.migration
  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: <<?0, ?0 + i>>
  defp pad(i), do: to_string(i)

  defp fuzzy_search(path, base_name, name) do
    fuzzy_path = Path.join(path, "*_#{base_name}")
    if Path.wildcard(fuzzy_path) != [] do
      Mix.raise "migration can't be created, there is already a migration file with name #{name}."
    end
  end

  embed_template :seed, """
  defmodule <%= inspect @mod %> do
    import Seedex

    alias <%= inspect @repo %>

  end
  """
end
