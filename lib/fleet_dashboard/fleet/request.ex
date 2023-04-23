defmodule FleetDashboard.Fleet.Request do
  use Ecto.Schema
  import Ecto.Changeset

  alias FleetDashboard.Accounts.User

  schema "requests" do
    field :finish, :string
    field :start, :string
    # field :user_id, :id
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(request, attrs) do
    request
    |> cast(attrs, [:start, :finish, :user_id])
    |> validate_required([:start, :finish, :user_id])
  end
end
