defmodule Group do
  use Ecto.Schema

  schema "groups" do
    field(:name, :string)
  end
end

defmodule User do
  use Ecto.Schema

  schema "users" do
    field(:name, :string)
    field(:age, :integer)
    field(:label, :string, virtual: true)

    belongs_to(:group, Group, on_replace: :nilify)
  end
end
