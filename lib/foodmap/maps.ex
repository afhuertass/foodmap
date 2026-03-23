defmodule Foodmap.Maps do
  use Ash.Domain,
    otp_app: :foodmap

  resources do
    resource Foodmap.Maps.Place

    resource Foodmap.Maps.PlaceUser do
      define :follow_map do
        action :create
        args [:place]

        custom_input :place, :struct do
          constraints instance_of: Foodmap.Maps.Place
          transform to: :place_id, using: & &1.id
        end
      end
    end
  end
end
