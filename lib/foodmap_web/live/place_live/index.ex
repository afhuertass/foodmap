defmodule FoodmapWeb.PlaceLive.Index do
  use FoodmapWeb, :live_view

  on_mount {FoodmapWeb.LiveUserAuth, :live_user_required}
  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Places
        <:actions>
          <.button variant="primary" navigate={~p"/places/new"}>
            <.icon name="hero-plus" /> New Place
          </.button>
        </:actions>
      </.header>

      <.table
        id="places"
        rows={@streams.places}
        row_click={fn {_id, place} -> JS.navigate(~p"/places/#{place}") end}
      >
        <:col :let={{_id, place}} label="Id">{place.id}</:col>

        <:action :let={{_id, place}}>
          <div class="sr-only">
            <.link navigate={~p"/places/#{place}"}>Show</.link>
          </div>

          <.link navigate={~p"/places/#{place}/edit"}>Edit</.link>
        </:action>

        <:action :let={{id, place}}>
          <.link
            phx-click={JS.push("delete", value: %{id: place.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
      <nav class="flex gap-4 items-center">
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
    {:ok,
     socket
     |> assign(:page_title, "Listing Places")
     |> assign_new(:current_user, fn -> nil end)
     |> stream(:places, Ash.read!(Foodmap.Maps.Place, actor: socket.assigns[:current_user]))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    place = Ash.get!(Foodmap.Maps.Place, id, actor: socket.assigns.current_user)
    Ash.destroy!(place, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :places, place)}
  end
end
