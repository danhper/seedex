defmodule SeedexTest do
  use Seedex.Case

  import Seedex

  test "seed inserts list of maps" do
    seed(User, [%{name: "Daniel", age: 26}, %{name: "Ai", age: 24}])
    assert %User{age: 26} = Repo.get_by!(User, name: "Daniel")
    assert %User{age: 24} = Repo.get_by!(User, name: "Ai")
  end

  test "seed inserts data returned by function" do
    seed(User, fn user ->
      user
      |> Map.put(:name, "Daniel")
      |> Map.put(:age, 26)
    end)

    assert %User{age: 26} = Repo.get_by!(User, name: "Daniel")
  end

  test "seed inserts data and applies function" do
    seed(User, [%{name: "Daniel"}, %{name: "Tom"}], fn user ->
      user |> Map.put(:age, 26)
    end)

    assert %User{age: 26} = Repo.get_by!(User, name: "Daniel")
    assert %User{age: 26} = Repo.get_by!(User, name: "Tom")
  end

  test "seed_once inserts data and applies function" do
    seed_once(User, [:name], [%{name: "Daniel"}, %{name: "Daniel"}], fn user ->
      user |> Map.put(:age, 26)
    end)

    assert %User{age: 26} = Repo.get_by!(User, name: "Daniel")
  end

  test "seed updates existing records" do
    Repo.insert!(%User{name: "Daniel", age: 26})
    seed(User, [:name], [%{name: "Daniel", age: 27}])
    assert %User{age: 27} = Repo.get_by!(User, name: "Daniel")
  end

  test "seed_once skips existing records" do
    Repo.insert!(%User{name: "Daniel", age: 26})
    seed_once(User, [:name], [%{name: "Daniel", age: 27}])
    assert %User{age: 26} = Repo.get_by!(User, name: "Daniel")
  end

  test "updates skip virtual fields and preserve database metadata" do
    original = Repo.insert!(%User{name: "Daniel", age: 26})
    seed(User, [:name], [%{name: "Daniel", age: 27, label: "not persisted"}])

    assert %User{id: id, age: 27, label: nil, __meta__: %{state: :loaded}} =
             Repo.get!(User, original.id)

    assert id == original.id
  end

  test "updates accept loaded associations" do
    old_group = Repo.insert!(%Group{name: "old"})
    new_group = Repo.insert!(%Group{name: "new"})
    user = Repo.insert!(%User{name: "Daniel", group_id: old_group.id})
    seed(User, [:name], fn record -> %{record | name: "Daniel", group: new_group} end)
    assert Repo.get!(User, user.id).group_id == new_group.id
  end

  test "invalid inserts raise instead of silently skipping data" do
    seed(User, [%{id: 100, name: "Daniel"}])
    assert_raise Ecto.ConstraintError, fn -> seed(User, [:name], [%{id: 100, name: "Ai"}]) end
  end
end
