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
          </.header>

          <div
            id="map-container"
            phx-hook="MapHook"
            phx-update="ignore"
            class="w-full h-[400px] mb-6 border rounded-xl overflow-hidden shadow-sm"
          >
          </div>
          <.header>
            Followed Places
            <:subtitle>
              Your Favorite places
            </:subtitle>
            <:actions>
              <.button variant="primary" navigate={~p"/places/new"}>
                <.icon name="hero-plus" class="mr-2 h-4 w-4" /> New Place
              </.button>
            </:actions>
          </.header>
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

          <.header>
            Your Friends Followed Places
            <:subtitle>
              Your friends favorite places
            </:subtitle>
          </.header>

          <.table
            id="places"
            rows={@streams.friends_places}
            row_click={fn {_id, place} -> JS.navigate(~p"/places/#{place}") end}
          >
            <:col :let={{_id, place}} label="Name">{place.name}</:col>
          </.table>
        </div>

        <div class="w-full lg:w-80 border-l border-zinc-200 dark:border-zinc-800 pl-8 bg-zinc-50 dark:bg-zinc-900 rounded-xl p-4 transition-colors">
          <h2 class="text-xl font-semibold mb-4 text-zinc-900 dark:text-white">Community</h2>
          <div id="users-list" class="space-y-4">
            <div
              :for={user <- @users}
              id={user.id}
              class="flex items-center justify-between p-2 hover:bg-zinc-200 dark:hover:bg-zinc-800 rounded-lg transition-colors"
            >
              <div class="flex flex-col">
                <span class="font-medium text-zinc-900 dark:text-white text-sm">
                  {to_string(user.email)}
                </span>
                <span class="text-xs text-zinc-500 dark:text-zinc-400">
                  <%= cond do %>
                    <% Enum.any?(@current_user.outbound_friendships, &(&1.friend_id == user.id && &1.status == :accepted)) -> %>
                      <span class="text-green-600 dark:text-green-400">Friend</span>
                    <% Enum.any?(@current_user.inbound_friendships, &(&1.user_id == user.id && &1.status == :accepted)) -> %>
                      <span class="text-green-600 dark:text-green-400">Friend</span>
                    <% Enum.any?(@current_user.outbound_friendships, &(&1.friend_id == user.id && &1.status == :pending)) -> %>
                      Waiting for response
                    <% Enum.any?(@current_user.inbound_friendships, &(&1.user_id == user.id && &1.status == :pending)) -> %>
                      Sent you a request
                    <% true -> %>
                      Member
                  <% end %>
                </span>
              </div>

              <div>
                <%= cond do %>
                  <% Enum.any?(@current_user.inbound_friendships, &(&1.user_id == user.id && &1.status == :pending)) -> %>
                    <.button
                      phx-click="accept_friendship"
                      phx-value-id={user.id}
                      variant="primary"
                      class="text-xs py-1 px-2"
                    >
                      Accept
                    </.button>
                  <% Enum.any?(@current_user.outbound_friendships, &(&1.friend_id == user.id)) or 
                 Enum.any?(@current_user.inbound_friendships, &(&1.user_id == user.id)) -> %>
                    <.icon name="hero-check-circle" class="w-5 h-5 text-zinc-400 dark:text-zinc-500" />
                  <% true -> %>
                    <.button
                      phx-click="send_friend_request"
                      phx-value-id={user.id}
                      variant="primary"
                      class="text-xs py-1 px-2"
                    >
                      Add
                    </.button>
                <% end %>
              </div>
            </div>
          </div>
        </div>
      </div>

      <nav class="flex gap-4 items-center mt-12 border-t border-zinc-200 dark:border-zinc-800 pt-4 text-zinc-600 dark:text-zinc-400">
        <%= if @current_user do %>
          <span class="text-sm">{@current_user.email}</span>
          <.link
            href={~p"/sign-out"}
            method="get"
            class="text-sm underline hover:text-zinc-900 dark:hover:text-white"
          >
            Log out
          </.link>
        <% else %>
          <.link
            href={~p"/sign-in"}
            class="text-sm underline hover:text-zinc-900 dark:hover:text-white"
          >
            Log in
          </.link>
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
    IO.inspect(user)

    {:ok,
     socket
     |> assign(:page_title, "Listing Places")
     |> assign(:users, users)
     # the user with the loaded relationships
     |> assign(:current_user, user)
     |> stream(:friends_places, friends_followed_places)
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

    in_loaded_places = Ash.load!(in_friends, [user: [:followed_places]], actor: actor)

    out_places =
      out_loaded_places
      |> Enum.map(fn %{friend: %{followed_places: followed_places}} -> followed_places end)
      |> List.flatten()

    in_places =
      in_loaded_places
      |> Enum.map(fn %{user: %{followed_places: followed_places}} -> followed_places end)
      |> List.flatten()

    IO.inspect("Samarripa")
    IO.inspect(out_places ++ in_places)
    out_places ++ in_places
  end
end
