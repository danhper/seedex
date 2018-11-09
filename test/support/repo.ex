defmodule Seedex.Repo do
  use Ecto.Repo,
    otp_app: :seedex,
    adapter: Ecto.Adapters.Postgres
end
