defmodule User do
  use Ecto.Schema

  schema "users" do
    field :name, :string
    field :age,  :integer

    belongs_to :group, Group
  end
end

defmodule Group do
  use Ecto.Schema

  schema "groups" do
    field :name, :string
  end
end
