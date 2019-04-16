defmodule Seedex.Mixfile do
  use Mix.Project

  @version "0.2.1"

  def project do
    [app: :seedex,
     version: @version,
     elixir: "~> 1.1",
     description: "Seed data generation for Ecto",
     source_url: "https://github.com/danhper/seedex",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package(),
     deps: deps(),
     docs: [source_ref: "#{@version}", extras: ["README.md"], main: "readme"]]
  end

  def application do
    [applications: applications(Mix.env),
     description: 'Seed data generation for Ecto']
  end

  defp applications(:test), do: applications(:all) ++ [:ecto, :postgrex]
  defp applications(_all),  do: [:logger]

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_all),  do: ["lib"]

  defp deps do
    [{:ecto, "~> 1.1 or ~> 2.1 or ~> 3.0"},
     {:ecto_sql, "~> 3.0"},
     {:postgrex, "~> 0.13", only: [:test]},
     {:earmark,   "~> 1.0", only: :docs},
     {:ex_doc,    "~> 0.14", only: :docs}]
  end

  defp package do
    [
      maintainers: ["Daniel Perez"],
      files: ["lib", "mix.exs", "README.md"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/danhper/seedex",
        "Docs" => "http://hexdocs.pm/seedex/"
      }
    ]
  end
end
