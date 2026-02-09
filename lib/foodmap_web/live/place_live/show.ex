defmodule FoodmapWeb.PlaceLive.Show do
  use FoodmapWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Place {@place.id}
        <:subtitle>This is a place record from your database.</:subtitle>

        <:actions>
          <.button navigate={~p"/places"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/places/#{@place}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit Place
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Id">{@place.id}</:item>

        <:item title="Name">{@place.name}</:item>

        <:item title="Name">{@place.address}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Place")
     |> assign(:place, Ash.get!(Foodmap.Maps.Place, id, actor: socket.assigns.current_user))}
  end
end
