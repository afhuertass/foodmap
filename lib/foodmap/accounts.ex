defmodule Foodmap.Accounts do
  use Ash.Domain, otp_app: :foodmap, extensions: [AshAdmin.Domain]

  admin do
    show? true
  end

  resources do
    resource Foodmap.Accounts.Token
    resource Foodmap.Accounts.User
  end
end
