defmodule FoodmapWeb.Router do
  use FoodmapWeb, :router

  use AshAuthentication.Phoenix.Router

  import AshAuthentication.Plug.Helpers

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {FoodmapWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
    plug :set_actor, :user
  end

  scope "/", FoodmapWeb do
    pipe_through :browser

    ash_authentication_live_session :authentication_required,
      on_mount: {FoodmapWeb.LiveUserAuth, :live_user_required} do
      live "/places", PlaceLive.Index, :index

      # live "/places/new", PlaceLive.Form, :new
      # live "/places/:id/edit", PlaceLive.Form, :edit
      # live "/places/:id", PlaceLive.Show, :show
      # live "/places/:id/show/edit", PlaceLive.Show, :edit
    end

    ash_authentication_live_session :authenticated_routes do
      # in each liveview, add one of the following at the top of the module:

      # live "/places", PlaceLive.Index, :index
      # live "/places/new", PlaceLive.Form, :new
      # live "/places/:id/edit", PlaceLive.Form, :edit
      #
      # live "/places/:id", PlaceLive.Show, :show
      # live "/places/:id/show/edit", PlaceLive.Show, :edit
      #
      # If an authenticated user must be present:
      # on_mount {FoodmapWeb.LiveUserAuth, :live_user_required}
      #
      # If an authenticated user *may* be present:
      # on_mount {FoodmapWeb.LiveUserAuth, :live_user_optional}
      #
      # If an authenticated user must *not* be present:
      # on_mount {FoodmapWeb.LiveUserAuth, :live_no_user}
    end
  end

  scope "/", FoodmapWeb do
    pipe_through :browser

    get "/", PageController, :home
    auth_routes AuthController, Foodmap.Accounts.User, path: "/auth"
    sign_out_route AuthController

    # Remove these if you'd like to use your own authentication views
    sign_in_route register_path: "/register",
                  reset_path: "/reset",
                  auth_routes_prefix: "/auth",
                  on_mount: [{FoodmapWeb.LiveUserAuth, :live_no_user}],
                  overrides: [
                    FoodmapWeb.AuthOverrides,
                    Elixir.AshAuthentication.Phoenix.Overrides.DaisyUI
                  ]

    # Remove this if you do not want to use the reset password feature
    reset_route auth_routes_prefix: "/auth",
                overrides: [
                  FoodmapWeb.AuthOverrides,
                  Elixir.AshAuthentication.Phoenix.Overrides.DaisyUI
                ]

    # Remove this if you do not use the confirmation strategy
    confirm_route Foodmap.Accounts.User, :confirm_new_user,
      auth_routes_prefix: "/auth",
      overrides: [FoodmapWeb.AuthOverrides, Elixir.AshAuthentication.Phoenix.Overrides.DaisyUI]

    # Remove this if you do not use the magic link strategy.
    magic_sign_in_route(Foodmap.Accounts.User, :magic_link,
      auth_routes_prefix: "/auth",
      overrides: [FoodmapWeb.AuthOverrides, Elixir.AshAuthentication.Phoenix.Overrides.DaisyUI]
    )
  end

  # Other scopes may use custom stacks.
  # scope "/api", FoodmapWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:foodmap, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: FoodmapWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  if Application.compile_env(:foodmap, :dev_routes) do
    import AshAdmin.Router

    scope "/admin" do
      pipe_through :browser

      ash_admin "/"
    end
  end
end
