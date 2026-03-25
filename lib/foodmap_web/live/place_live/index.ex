defmodule FoodmapWeb.PlaceLive.Index do
  use FoodmapWeb, :live_view

  on_mount {FoodmapWeb.LiveUserAuth, :live_user_required}
  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex flex-col lg:flex-row gap-8">
        <div class="flex-1">
          <.header>
            Listing Places
            <:actions>
              <.button variant="primary" navigate={~p"/places/new"}>
                <.icon name="hero-plus" /> New Place
              </.button>
            </:actions>
          </.header>

          <div id="map-container" phx-hook="MapHook" phx-update="ignore" class="w-full h-[400px] mb-6">
          </div>

          <.table
            id="places"
            rows={@streams.places}
            row_click={fn {_id, place} -> JS.navigate(~p"/places/#{place}") end}
          >
            <:col :let={{_id, place}} label="Name">{place.name}</:col>
            <:action :let={{_id, place}}>
              <.link navigate={~p"/places/#{place}/edit"}>Edit</.link>
            </:action>
          </.table>
        </div>

        <div class="w-full lg:w-80 border-l pl-8">
          <h2 class="text-xl font-semibold mb-4 text-zinc-800">Community</h2>
          <div id="users-list" phx-update="stream" class="space-y-4 text-white">
            <div
              :for={{id, user} <- @users}
              id={id}
              class="flex items-center justify-between p-2 hover:bg-zinc-50 rounded-lg white-text"
            >
              <div class="flex flex-col text-white">
                <span class="font-medium text-white">{user}</span>
                <span class="text-xs text-zinc-500">Member</span>
              </div>

              <.button
                phx-click="send_friend_request"
                phx-value-id={id}
                variant="primary"
              >
                Add
              </.button>
            </div>
          </div>
        </div>
      </div>

      <nav class="flex gap-4 items-center mt-12 border-t pt-4">
        <%= if @current_user do %>
          <span>{@current_user.email}</span>
          <.link href={~p"/sign-out"} method="get" class="underline">Log out</.link>
        <% else %>
          <.link href={~p"/sign-in"} class="underline">Log in</.link>
        <% end %>
      </nav>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    places = Ash.read!(Foodmap.Maps.Place, actor: socket.assigns[:current_user])

    users =
      Foodmap.Accounts.User
      |> Ash.Query.for_read(:list_users)
      |> Ash.read!()
      |> Enum.map(fn %{id: id, email: email} -> {id, email.string} end)
      |> Enum.filter(fn {id, _} -> id != socket.assigns.current_user.id end)

    current_user = Ash.load(socket.assigns.current_user, :followed_places)

    IO.inspect(current_user)

    {:ok,
     socket
     |> assign(:page_title, "Listing Places")
     |> assign(:users, users)
     |> assign_new(:current_user, fn -> nil end)
     |> push_event("init_markers", %{places: serialize_places(places)})
     |> stream(:places, places)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    place = Ash.get!(Foodmap.Maps.Place, id, actor: socket.assigns.current_user)
    Ash.destroy!(place, actor: socket.assigns.current_user)

    {:noreply,
     stream_delete(socket, :places, place) |> push_event("remove_marker", %{id: place.id})}
  end

  def serialize_places(places) do
    Enum.map(places, fn place ->
      %{id: place.id, name: place.name, lat: place.lat, lng: place.lng}
    end)
  end
end
