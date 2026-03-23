defmodule Foodmap.Maps do
  use Ash.Domain,
    otp_app: :foodmap

  resources do
    resource Foodmap.Maps.Place

    resource Foodmap.Maps.PlaceUser do
      define :follow_map do
        action :create
        args [:user]

        custom_input :user, :struct do
          constraints instance_of: Foodmap.Accounts.User
          transform to: :user_id, using: & &1.id
        end
      end
    end
  end
end
