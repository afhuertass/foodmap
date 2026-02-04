defmodule Foodmap.Maps do
  use Ash.Domain,
    otp_app: :foodmap

  resources do
    resource Foodmap.Maps.Place
    resource Foodmap.Maps.PlaceUser
  end
end
