defmodule Mix.Tasks.Seedex.SeedTest do
  use Seedex.Case

  test "seed task" do
    Mix.Tasks.Seedex.Seed.run([])

    assert %Group{name: "admin"} = Repo.get!(Group, 1)
    assert %User{group_id: 1} = Repo.get_by!(User, name: "Daniel")

    assert_raise Mix.Error, fn ->
      Mix.Tasks.Seedex.Seed.run(["--seeds-path", "/foo/bar"])
    end
  end

  test "seed task with update" do
    Repo.insert!(%Group{id: 2, name: "user"})
    Repo.insert!(%User{name: "Daniel", group_id: 2})
    Mix.Tasks.Seedex.Seed.run([])

    assert %Group{name: "admin"} = Repo.get!(Group, 1)
    assert %User{group_id: 1} = Repo.get_by!(User, name: "Daniel")
  end
end
