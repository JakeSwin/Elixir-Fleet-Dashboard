defmodule FleetDashboardWeb.SimpleSubmitTaskLive do
  use FleetDashboardWeb, :live_component

  alias FleetDashboard.Fleet
  alias FleetDashboard.Fleet.Request

  def mount(socket) do
    {:ok,
      socket
      |> assign_request()
      |> assign_changeset()
      |> assign_form()}
  end

  def render(assigns) do
    ~H"""
    <div>
      <%= if @available_robots do %>
      <.simple_form
        for={@form}
        id="task-request-form"
        phx-target={@myself}
        phx-submit="save"
        phx-change="validate">
        <.input field={@form[:start]} type="select" options={@locations} label="Go to" />
        <:actions>
          <.button phx-disable-with="Sending...">Send Task Request</.button>
        </:actions>
      </.simple_form>
      <% else %>
        <div class="mt-5 text-xl text-red-500">Connecting to fleet... Please wait</div>
      <% end %>
    </div>
    """
  end

  def handle_event("save",
  %{"request" => request_params},
  %{assigns: %{current_user: user}} = socket) do
    request_params =
      request_params
      |> Map.put("finish", request_params["start"])
      |> Map.put("user_id", user.id)

    case Fleet.create_request(request_params) do
      {:ok, request} ->
        changeset = Fleet.change_request(request)
        FleetMonitor.submit_task(request_params["start"], request_params["finish"])
        Phoenix.PubSub.broadcast!(FleetMonitor.PubSub, "new_request", {:new_request, request})
        {:noreply, socket |> assign(changeset: changeset) |> assign_form()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(changeset: changeset) |> assign_form()}
    end
  end

  def handle_event("validate",
  %{"request" => request_params},
  %{assigns: %{request: request, current_user: user}} = socket) do
    request_params =
      request_params
      |> Map.put("finish", request_params["start"])
      |> Map.put("user_id", user.id)

    changeset =
      request
      |> Fleet.change_request(request_params)
      |> Map.put(:action, :validate)

    {:noreply,
      socket
      |> assign(changeset: changeset)
      |> assign_form()}
  end

  def assign_request(socket) do
    socket
    |> assign(request: %Request{})
  end

  def assign_changeset(%{assigns: %{request: request}} = socket) do
    socket
    |> assign(changeset: Fleet.change_request(request))
  end

  def assign_form(%{assigns: %{changeset: changeset}} = socket) do
    socket
    |> assign(form: to_form(changeset))
  end

  def random_finish(nil, locations), do: Enum.random(locations)
  def random_finish([], locations), do: Enum.random(locations)
  def random_finish(robots, _locations) do
    Enum.random(robots) <> "_charger"
  end
end
