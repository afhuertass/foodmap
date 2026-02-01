defmodule Foodmap.Secrets do
  use AshAuthentication.Secret

  def secret_for(
        [:authentication, :tokens, :signing_secret],
        Foodmap.Accounts.User,
        _opts,
        _context
      ) do
    Application.fetch_env(:foodmap, :token_signing_secret)
  end
end
