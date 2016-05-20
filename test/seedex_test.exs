defmodule SeedexTest do
  use Seedex.Case

  import Seedex

  test "seed inserts list of maps" do
    seed User, [%{name: "Daniel", age: 26}, %{name: "Ai", age: 24}]
    assert %User{age: 26} = Repo.get_by!(User, name: "Daniel")
    assert %User{age: 24} = Repo.get_by!(User, name: "Ai")
  end

  test "seed inserts data returned by function" do
    seed User, fn user ->
      user
      |> Map.put(:name, "Daniel")
      |> Map.put(:age, 26)
    end
    assert %User{age: 26} = Repo.get_by!(User, name: "Daniel")
  end

  test "seed updates existing records" do
    Repo.insert!(%User{name: "Daniel", age: 26})
    seed User, [:name], [%{name: "Daniel", age: 27}]
    assert %User{age: 27} = Repo.get_by!(User, name: "Daniel")
  end

  test "seed_once skips existing records" do
    Repo.insert!(%User{name: "Daniel", age: 26})
    seed_once User, [:name], [%{name: "Daniel", age: 27}]
    assert %User{age: 26} = Repo.get_by!(User, name: "Daniel")
  end
end
