defmodule FoodmapWeb.ErrorJSONTest do
  use FoodmapWeb.ConnCase, async: true

  test "renders 404" do
    assert FoodmapWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert FoodmapWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
