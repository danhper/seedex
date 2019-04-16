defmodule Seedex do
  @moduledoc """
  Functions to populate database with seed data.
  """

  require Logger

  @doc """
  `seed/3` inserts data in the given table

  ## Arguments

    * `module` - The module containing the Ecto schema.
    * `contraints` - The fields used to idenfity a record. The record will be updated
      if a record with matching fields already exist.
    * `data` - The data to insert. It can either be a list of maps, each containing a record
      or a function which takes a `struct` as input and output.

  ## Examples

    ```elixir
    seed MyApp.Point, [:x, :y], fn point ->
      point
      |> Map.put(:x, 4)
      |> Map.put(:y, 7)
      |> Map.put(:name, "Home")
    end

    seed MyApp.User, [
      %{name: "Daniel", age: 26},
      %{name: "Ai", age: 24}
    ]
    ```
  """
  @spec seed(module :: atom, constraints :: [atom], data :: (() -> :ok) | [map]) :: :ok
  def seed(module, constraints \\ [:id], data) do
    do_seed(module, constraints, data, update: true)
  end

  @doc """
  Same as `seed/3` but does not update the record if it already exists
  """
  @spec seed_once(module :: atom, constraints :: [atom], data :: (() -> :ok) | [map]) :: :ok
  def seed_once(module, constraints \\ [:id], data) do
    do_seed(module, constraints, data, update: false)
  end

  defp do_seed(module, constraints, func, opts) when is_function(func, 1) do
    record = func.(struct(module, %{}))
    insert_seed(module, record, constraints, opts)
  end

  defp do_seed(module, constraints, data, opts) when is_list(data) do
    Enum.each data, fn record ->
      record = struct(module, record)
      insert_seed(module, record, constraints, opts)
    end
  end

  defp insert_seed(module, record, constraints, opts) do
    existing = fetch_record(module, record, constraints)
    cond do
      existing && opts[:update] ->
        update_record(record, existing)
      !existing ->
        Logger.debug("Inserting record #{inspect(record)}")
        repo().insert(record)
      true ->
        :ok
    end
  end

  defp fetch_record(module, record, constraints) do
    case make_query(record, constraints) do
      [] ->
        nil
      query ->
        repo().get_by(module, query)
    end
  end

  defp make_query(record, constraints) do
    constraints
    |> Enum.map(& {&1, Map.fetch!(record, &1)})
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
  end

  defp update_record(record, existing) do
    changeset = make_changeset(record, existing)
    Logger.debug("Updating #{inspect(record)} with changes: #{inspect(changeset.changes)}")
    repo().update!(changeset)
  end

  defp make_changeset(record, existing) do
    {changeset, changes} = {Ecto.Changeset.change(existing), Map.from_struct(record)}
    Enum.reduce changes, changeset, fn
      {_key, %Ecto.Association.NotLoaded{}}, changeset ->
        changeset
      {_key, nil}, changeset ->
        changeset
      {key, _value}, changeset when key in ["__meta__", :__meta__] ->
        changeset
      {key, %Ecto.Association.BelongsTo{} = assoc}, changeset ->
        Ecto.Changeset.put_assoc(changeset, key, assoc)
      {key, value}, changeset ->
        Ecto.Changeset.put_change(changeset, key, value)
    end
  end

  defp repo do
    Application.get_env(:seedex, :repo)
  end
end
