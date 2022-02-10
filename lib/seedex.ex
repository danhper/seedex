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
      if a record with matching fields already exist. The default value is `[:id]`
    * `data` - The data to insert. It should be a list of maps. If it is not passed,
      a single record will be created using the function passed.
    * `process` - A function to post-process each created record. It is required
      only if `data` is omitted.

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
  @spec seed(module :: atom, constraints :: [atom], data :: [map], process :: (struct -> struct)) ::
          :ok
  def seed(module, constraints \\ [:id], data \\ [], process \\ nil) do
    dispatch_seed(module, constraints, data, process, update: true)
  end

  @doc """
  Same as `seed/3` but does not update the record if it already exists
  """
  @spec seed_once(
          module :: atom,
          constraints :: [atom],
          data :: (struct -> struct) | [map],
          process :: (struct -> struct)
        ) :: :ok
  def seed_once(module, constraints \\ [:id], data \\ [], process \\ nil) do
    dispatch_seed(module, constraints, data, process, update: false)
  end

  defp identity(x), do: x

  # arguments were all pased
  defp dispatch_seed(module, constraints, data, func, opts) when is_function(func, 1),
    do: do_seed(module, constraints, data, func, opts)

  # 3 arguments passed
  defp dispatch_seed(module, [h | t], data, nil, opts) when is_atom(h) and is_list(data),
    do: do_seed(module, [h | t], data, &identity/1, opts)

  defp dispatch_seed(module, [h | t], func, nil, opts) when is_atom(h) and is_function(func, 1),
    do: do_seed(module, [h | t], [], func, opts)

  defp dispatch_seed(module, [h | t], func, nil, opts) when is_map(h) and is_function(func, 1),
    do: do_seed(module, [:id], [h | t], func, opts)

  # 2 arguments passed
  defp dispatch_seed(module, func, [], nil, opts) when is_function(func, 1),
    do: do_seed(module, [:id], [], func, opts)

  defp dispatch_seed(module, [h | t], [], nil, opts) when is_map(h),
    do: do_seed(module, [:id], [h | t], &identity/1, opts)

  defp dispatch_seed(_module, _constraints, _data, _func, _opts),
    do: raise(ArgumentError, "invalid arguments to seed")

  defp do_seed(module, constraints, [], process, opts),
    do: do_seed(module, constraints, [%{}], process, opts)

  defp do_seed(module, constraints, data, process, opts) do
    Enum.each(data, fn record ->
      record = struct(module, record) |> process.()
      insert_seed(module, record, constraints, opts)
    end)
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
    |> Enum.map(&{&1, Map.fetch!(record, &1)})
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
  end

  defp update_record(record, existing) do
    changeset = make_changeset(record, existing)
    Logger.debug("Updating #{inspect(record)} with changes: #{inspect(changeset.changes)}")
    repo().update!(changeset)
  end

  defp make_changeset(record, existing) do
    {changeset, changes} = {Ecto.Changeset.change(existing), Map.from_struct(record)}

    Enum.reduce(changes, changeset, fn
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
    end)
  end

  defp repo do
    Application.get_env(:seedex, :repo)
  end
end
