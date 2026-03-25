defmodule Foodmap.Maps.Place do
  use Ash.Resource,
    otp_app: :foodmap,
    domain: Foodmap.Maps,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "places"
    repo Foodmap.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true
      accept [:name, :lat, :lng]

      # argument :user_id, :uuid, allow_nil?: false

      # 2. Tell Ash to use that ID to create a record in the join table
      # change manage_relationship(actor(:id), :followers, type: :create)
    end
  end

  policies do
    policy action_type(:read) do
      authorize_if always()
    end

    policy action_type(:create) do
      authorize_if always()
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :lat, :float
    attribute :lng, :float
  end

  relationships do
    has_many :follower_relationships, Foodmap.Maps.PlaceUser

    many_to_many :followers, Foodmap.Accounts.User do
      through Foodmap.Maps.PlaceUser
      source_attribute_on_join_resource :place_id
      destination_attribute_on_join_resource :user_id
    end
  end

  calculations do
    calculate :followed_by_me,
              :boolean,
              expr(exists(follower_relationships, user_id == ^actor(:id))) do
      public? true
    end
  end
end
