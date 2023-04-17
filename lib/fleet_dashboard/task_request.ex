defmodule FleetDashboard.TaskRequest do
  defstruct [
    :start,
    :finish
  ]
  @types %{start: :string, finish: :string}

  import Ecto.Changeset

  def changeset(%__MODULE__{} = task_request, attrs \\ %{}) do
    {task_request, @types}
    |> cast(attrs, Map.keys(@types))
    |> validate_required([:start, :finish])
  end
end
