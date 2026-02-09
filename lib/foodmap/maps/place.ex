defmodule Foodmap.Maps.Place do
  use Ash.Resource, otp_app: :foodmap, domain: Foodmap.Maps, data_layer: AshPostgres.DataLayer

  postgres do
    table "places"
    repo Foodmap.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      accept [:name, :lat, :lng, :address]
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :address, :string
    attribute :lat, :float
    attribute :lng, :float
  end

  relationships do
    has_many :follower_relationships, Foodmap.Maps.PlaceUser

    many_to_many :followers, Foodmap.Accounts.User do
      join_relationship :follower_relationships
      destination_attribute_on_join_resource :place_id
    end
  end
end
