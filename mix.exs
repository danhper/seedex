defmodule Seedex.Mixfile do
  use Mix.Project

  @version "0.4.0"

  def project do
    [
      app: :seedex,
      version: @version,
      elixir: "~> 1.15",
      description: "Seed data generation for Ecto",
      source_url: "https://github.com/danhper/seedex",
      elixirc_paths: elixirc_paths(Mix.env()),
      test_ignore_filters: [~r/^test\/seeds\//],
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: [source_ref: "#{@version}", extras: ["README.md"], main: "readme"]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_all), do: ["lib"]

  defp deps do
    [
      {:ecto, "~> 3.13"},
      {:ecto_sql, "~> 3.13"},
      {:postgrex, "~> 0.22", only: :test},
      {:ex_doc, "~> 0.40", only: :docs, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Daniel Perez"],
      files: ["lib", "mix.exs", "README.md", "CHANGELOG.md", "LICENSE"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/danhper/seedex",
        "Docs" => "http://hexdocs.pm/seedex/"
      }
    ]
  end
end
