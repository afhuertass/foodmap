defmodule FoodmapWeb.PlaceLive.Form do
  use FoodmapWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage place records in your database.</:subtitle>
      </.header>

      <.form
        for={@form}
        id="place-form"
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:address]} type="text" label="Address" />

        <.input field={@form[:lat]} type="number" label="Latitude" />
        <.input field={@form[:lng]} type="number" label="Longitude" />
        <.button phx-disable-with="Saving..." variant="primary">Save Place</.button>
        <.button navigate={return_path(@return_to, @place)}>Cancel</.button>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    place =
      case params["id"] do
        nil -> nil
        id -> Ash.get!(Foodmap.Maps.Place, id, actor: socket.assigns.current_user)
      end

    action = if is_nil(place), do: "New", else: "Edit"
    page_title = action <> " " <> "Place"

    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(place: place)
     |> assign(:page_title, page_title)
     |> assign_form()}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  @impl true
  def handle_event("validate", %{"place" => place_params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, place_params)
    IO.inspect(AshPhoenix.Form.params(form), label: "Form Params after Ash processing")
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"place" => place_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: place_params) do
      {:ok, place} ->
        notify_parent({:saved, place})

        socket =
          socket
          |> put_flash(:info, "Place #{socket.assigns.form.source.type}d successfully")
          |> push_navigate(to: return_path(socket.assigns.return_to, place))

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{place: place}} = socket) do
    form =
      if place do
        AshPhoenix.Form.for_update(place, :update,
          as: "place",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Foodmap.Maps.Place, :create,
          as: "place",
          actor: socket.assigns.current_user,
          params: %{"user_id" => socket.assigns.current_user.id}
        )
      end

    assign(socket, form: to_form(form))
  end

  defp return_path("index", _place), do: ~p"/places"
  defp return_path("show", place), do: ~p"/places/#{place.id}"
end
