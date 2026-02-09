defmodule FoodmapWeb.PageController do
  use FoodmapWeb, :controller

  def home(conn, _params) do
    if conn.assigns[:current_user] do
      redirect(conn, to: ~p"/places")
    else
      render(conn, :home)
    end
  end
end
