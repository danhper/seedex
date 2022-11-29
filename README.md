# Seedex

[![Build Status](https://travis-ci.org/danhper/seedex.svg?branch=master)](https://travis-ci.org/danhper/seedex)
[![Hex.pm](https://img.shields.io/hexpm/v/seedex.svg)](https://hex.pm/packages/seedex)

Seedex is a library for Ecto to easily populate your DB with seed data.
It is useful, for example, if you have some master data you need to
insert in your database.

This is not meant to generate data for your tests, if this is what
you need, checkout [ecto_fixtures](https://github.com/dockyard/ecto_fixtures) or
[ex_machina](https://github.com/thoughtbot/ex_machina) instead.

## Compatible versions

Version `0.3.0` or lower:

* Elixir ~> `1.11.x` or lower.

Version `0.4.0`:

* Elixir ~> `1.13.x`.

Version `0.5.0` or higher:

* Elixir ~> `1.14.x` or higher.

## Installation

Add `seedex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:seedex, "~> 0.3.0"}]
end
```

## Usage

First, you need to configure `seedex` to use your repository:

```elixir
config :seedex,
  repo: YourApp.Repo,
  seeds_path: "priv/repo/seeds" # not required, but can be used to customize seeds path
```

Then, you just need to add files under the `seeds_path`, which defaults to `priv/repo/seeds`.
All files matching `seeds_path/*.exs` and `seeds_path/MIX_ENV/*.exs` if it exists will be read.
To insert the data, you need to run

```
mix seedex.seed
```

Files are loaded in alphabetic order, independently of the directory they are in.
However, the files are really just plain Elixir with nothing special, so you could
just use `mix run priv/repo/seeds/my_seed.exs`, if you needed to.

### Sample seed file

Here is what a seed file looks like:

```elixir
import Seedex

seed_once Group, fn group ->
  group
  |> Map.put(:id, 1)
  |> Map.put(:name, "admin")
end

seed Group, fn group ->
  %{group | id: 2, name: "user"}
end

seed User, [:name], [
  %{name: "Daniel", age: 26, group_id: 1},
  %{name: "Ai", age: 24, group_id: 2},
]
```

Checkout the [documentation](https://hexdocs.pm/seedex/Seedex.html) for more info.
