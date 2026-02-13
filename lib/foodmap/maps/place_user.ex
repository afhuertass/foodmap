defmodule Foodmap.Maps.PlaceUser do
  use Ash.Resource,
    otp_app: :foodmap,
    domain: Foodmap.Maps,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  # This resource is used to link Places to User via a many to many relationship. One user can many places that it likes and a place can have many users that it is favorite of
  postgres do
    table "place_users"
    repo Foodmap.Repo

    references do
      reference :user, on_delete: :delete, index?: true
      reference :place, on_delete: :delete
    end
  end

  actions do
    defaults [:read]

    create :create do
      primary? true
      accept [:user_id, :place_id]
    end
  end

  relationships do
    belongs_to :place, Foodmap.Maps.Place do
      primary_key? true
      allow_nil? false
    end

    belongs_to :user, Foodmap.Accounts.User do
      primary_key? true
      allow_nil? false
    end
  end
end
