import Seedex

seed Group, fn group ->
  group
  |> Map.put(:id, 1)
  |> Map.put(:name, "admin")
end

seed Group, fn group ->
  %{group | id: 2, name: "user"}
end
