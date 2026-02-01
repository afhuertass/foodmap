defmodule FoodmapWeb.PageController do
  use FoodmapWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
