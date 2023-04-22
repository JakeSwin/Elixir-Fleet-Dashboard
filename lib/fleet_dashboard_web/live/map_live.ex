defmodule FleetDashboardWeb.MapLive do
  use FleetDashboardWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>Hello</div>
    """
  end
end