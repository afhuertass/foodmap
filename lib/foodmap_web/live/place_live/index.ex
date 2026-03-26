defmodule FoodmapWeb.PlaceLive.Index do
  use FoodmapWeb, :live_view
  import Ash.Query

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
            rows={@streams.places_followed}
            row_click={fn {_id, place} -> JS.navigate(~p"/places/#{place}") end}
          >
            <:col :let={{_id, place}} label="Name">{place.name}</:col>
            <:action :let={{_id, place}}>
              <.link navigate={~p"/places/#{place}/edit"}>Edit</.link>
            </:action>
          </.table>
        </div>

        <div class="w-full lg:w-80 border-l pl-8 bg-zinc-900 rounded-xl p-4">
          <h2 class="text-xl font-semibold mb-4 text-white">Community</h2>
          <div id="users-list" class="space-y-4">
            <div
              :for={user <- @users}
              id={user.id}
              class="flex items-center justify-between p-2 hover:bg-zinc-800 rounded-lg transition-colors"
            >
              <div class="flex flex-col">
                <span class="font-medium text-white text-sm">{to_string(user.email)}</span>
                <span class="text-xs text-zinc-400">
                  <%!-- Logic to determine label --%>
                  <%= cond do %>
                    <% Enum.any?(@current_user.outbound_friendships, &(&1.friend_id == user.id && &1.status == :accepted)) -> %>
                      <span class="text-green-400">Friend</span>
                    <% Enum.any?(@current_user.inbound_friendships, &(&1.user_id == user.id && &1.status == :accepted)) -> %>
                      <span class="text-green-400">Friend</span>
                    <% Enum.any?(@current_user.outbound_friendships, &(&1.friend_id == user.id && &1.status == :pending)) -> %>
                      Waiting for response
                    <% Enum.any?(@current_user.inbound_friendships, &(&1.user_id == user.id && &1.status == :pending)) -> %>
                      Sent you a request
                    <% true -> %>
                      Member
                  <% end %>
                </span>
              </div>

              <%!-- Logic to determine button --%>
              <div>
                <%= cond do %>
                  <% Enum.any?(@current_user.inbound_friendships, &(&1.user_id == user.id && &1.status == :pending)) -> %>
                    <.button
                      phx-click="accept_friendship"
                      phx-value-id={user.id}
                      class="!bg-white !text-black"
                    >
                      Accept
                    </.button>
                  <% Enum.any?(@current_user.outbound_friendships, &(&1.friend_id == user.id)) or 
             Enum.any?(@current_user.inbound_friendships, &(&1.user_id == user.id)) -> %>
                    <%!-- Show nothing or a 'Friends' icon if relationship exists --%>
                    <.icon name="hero-check-circle" class="w-5 h-5 text-zinc-500" />
                  <% true -> %>
                    <.button
                      phx-click="send_friend_request"
                      phx-value-id={user.id}
                      variant="primary"
                    >
                      Add
                    </.button>
                <% end %>
              </div>
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
    # places = Ash.read!(Foodmap.Maps.Place, actor: socket.assigns[:current_user])

    users =
      Foodmap.Accounts.User
      |> Ash.Query.for_read(:list_users)
      |> Ash.read!()
      # |> Enum.map(fn %{id: id, email: email} -> {id, email.string} end)
      |> Enum.filter(fn %{id: id} -> id != socket.assigns.current_user.id end)

    # load the user with the followed places
    {_, user} =
      Ash.load(socket.assigns.current_user, [
        :followed_places,
        :inbound_friendships,
        :outbound_friendships
      ])

    # I want a list of the folloed places to assing to the socket
    # IO.inspect(user.followed_places)
    # lets load friends
    actor = socket.assigns.current_user

    friends_followed_places = get_friends_places_user(user, actor)
    # IO.inspect(user)

    {:ok,
     socket
     |> assign(:page_title, "Listing Places")
     |> assign(:users, users)
     # the user with the loaded relationships
     |> assign(:current_user, user)
     |> push_event("init_markers", %{places: serialize_places(user.followed_places)})
     |> push_event("friend_markers", %{places: serialize_places(friends_followed_places)})
     |> stream(:places_followed, user.followed_places)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    place = Ash.get!(Foodmap.Maps.Place, id, actor: socket.assigns.current_user)
    Ash.destroy!(place, actor: socket.assigns.current_user)

    {:noreply,
     stream_delete(socket, :places, place) |> push_event("remove_marker", %{id: place.id})}
  end

  @impl true
  def handle_event("send_friend_request", %{"id" => friend_id}, socket) do
    actor = socket.assigns.current_user

    # 1. Execute the Ash action
    # We use the :request action defined in your Friendship resource
    result =
      Foodmap.Accounts.Friendship
      |> Ash.Changeset.for_create(:request, %{friend_id: friend_id}, actor: actor)
      |> Ash.create(actor: actor)

    case result do
      {:ok, _friendship} ->
        # 2. Re-load the current user's relationships
        # This ensures the Enum.any? checks in your template find the new record
        user = Ash.load!(actor, [:outbound_friendships, :inbound_friendships], actor: actor)

        {:noreply,
         socket
         |> assign(:current_user, user)
         |> put_flash(:info, "Friend request sent!")}

      {:error, error} ->
        IO.inspect(error)
        {:noreply, put_flash(socket, :error, "Could not send friend request.")}
    end
  end

  @impl true
  def handle_event("accept_friendship", %{"id" => sender_id}, socket) do
    actor = socket.assigns.current_user

    {:ok, friendship} =
      Foodmap.Accounts.Friendship
      |> Ash.Query.for_read(:read, %{}, actor: actor)
      |> Ash.Query.filter(user_id: sender_id)
      |> Ash.read_one()

    IO.inspect(friendship)

    # |> Ash.update()
    update = friendship |> Ash.Changeset.for_update(:accept, %{}) |> Ash.update()

    IO.inspect(update)

    case update do
      {:ok, _} ->
        user = Ash.load!(actor, [:outbound_friendships, :inbound_friendships], actor: actor)
        {:noreply, assign(socket, :current_user, user) |> put_flash(:info, "Accepted!")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to accept.")}
    end
  end

  def serialize_places(places) do
    Enum.map(places, fn place ->
      %{id: place.id, name: place.name, lat: place.lat, lng: place.lng}
    end)
  end

  def get_friends_places_user(
        %{
          inbound_friendships: in_friends,
          outbound_friendships: out_friends
        },
        actor
      ) do
    out_loaded_places = Ash.load!(out_friends, [friend: [:followed_places]], actor: actor)

    in_loaded_places = Ash.load!(in_friends, [friend: [:followed_places]], actor: actor)

    out_places =
      out_loaded_places
      |> Enum.map(fn %{friend: %{followed_places: followed_places}} -> followed_places end)
      |> List.flatten()

    in_places =
      in_loaded_places
      |> Enum.map(fn %{friend: %{followed_places: followed_places}} -> followed_places end)
      |> List.flatten()

    IO.inspect(out_places ++ in_places)
    out_places ++ in_places
  end
end
