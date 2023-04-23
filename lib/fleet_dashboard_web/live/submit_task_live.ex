defmodule FleetDashboardWeb.SubmitTaskLive do
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
      <.simple_form
        for={@form}
        id="task-request-form"
        phx-target={@myself}
        phx-submit="save"
        phx-change="validate">
        <.input field={@form[:start]} type="select" options={@locations} label="Start location" />
        <.input field={@form[:finish]} type="select" options={@locations} label="Finish location" />
        <:actions>
          <.button phx-disable-with="Sending...">Send Task Request</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def handle_event("save", %{"request" => task_request_params}, %{assigns: %{current_user: user}} = socket) do
    case Fleet.create_request(Map.put(task_request_params, "user_id", user.id)) do
      {:ok, request} ->
        changeset = Fleet.change_request(request)
        FleetMonitor.submit_task(task_request_params["start"], task_request_params["finish"])
        Phoenix.PubSub.broadcast!(FleetMonitor.PubSub, "new_request", {:new_request, request})
        {:noreply, socket |> assign(changeset: changeset) |> assign_form()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(changeset: changeset) |> assign_form()}
    end
  end

  def handle_event("validate", %{"request" => task_request_params}, %{assigns: %{request: request, current_user: user}} = socket) do
    changeset =
      request
      |> Fleet.change_request(Map.put(task_request_params, "user_id", user.id))
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
end
