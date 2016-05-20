defmodule Seedex.Case do

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Seedex.Repo
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Seedex.Repo)
  end
end
