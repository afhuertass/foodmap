defmodule Foodmap.Accounts.Friendship do
  use Ash.Resource,
    domain: Foodmap.Accounts,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "friendships"
    repo Foodmap.Repo
  end

  actions do
    defaults [:read]

    # 1. Request Friendship
    create :request do
      accept [:friend_id]
      # Set the current user as the initiator automatically in the UI/Action
      change set_attribute(:status, :pending)
      change relate_actor(:user)
      # Prevent friending yourself
      validate compare(:user_id, is_not_equal: arg(:friend_id))
    end

    # 2. Accept Friendship
    update :accept do
      # Only allow transitioning from pending
      primary? true
      validate attribute_equals(:status, :pending)
      change set_attribute(:status, :accepted)
    end

    # 3. Decline or Unfriend
    destroy :remove do
      # Simple deletion works for both declining a request and unfriending
    end
  end

  attributes do
    uuid_primary_key :id

    # The status of the relationship
    attribute :status, :atom do
      constraints one_of: [:pending, :accepted, :declined]
      default :pending
      allow_nil? false
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    # The person who sent the request
    belongs_to :user, Foodmap.Accounts.User do
      allow_nil? false
      primary_key? true
    end

    # The person receiving the request
    belongs_to :friend, Foodmap.Accounts.User do
      allow_nil? false
      primary_key? true
    end
  end

  # This ensures we don't have duplicate rows for the same pair
  identities do
    identity :unique_friendship, [:user_id, :friend_id]
  end
end
