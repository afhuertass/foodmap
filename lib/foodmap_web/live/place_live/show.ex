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

      <div
        id="map-container"
        phx-hook="MapHook"
        phx-update="ignore"
        class="w-full h-[400px] mb-6 border rounded-xl overflow-hidden shadow-sm"
      >
      </div>
      <.list>
        <:item title="Id">{@place.id}</:item>

        <:item title="Name">{@place.name}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    place = Ash.get!(Foodmap.Maps.Place, id, actor: socket.assigns.current_user)
    aaa = Ash.load(place, :follower_relationships, actor: socket.assigns.current_user)
    IO.inspect(aaa)

    {:ok,
     socket
     |> assign(:page_title, "Show Place")
     |> push_event("set_marker", %{lat: place.lat, lng: place.lng})
     |> assign(:place, Ash.get!(Foodmap.Maps.Place, id, actor: socket.assigns.current_user))}
  end
end
