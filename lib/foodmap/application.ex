defmodule Foodmap.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FoodmapWeb.Telemetry,
      Foodmap.Repo,
      {DNSCluster, query: Application.get_env(:foodmap, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Foodmap.PubSub},
      # Start a worker by calling: Foodmap.Worker.start_link(arg)
      # {Foodmap.Worker, arg},
      # Start to serve requests, typically the last entry
      FoodmapWeb.Endpoint,
      {AshAuthentication.Supervisor, [otp_app: :foodmap]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Foodmap.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FoodmapWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
