Mix.Task.run "ecto.create", ~w(-r Seedex.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Seedex.Repo --quiet)

Seedex.Repo.start_link
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Seedex.Repo, :manual)
