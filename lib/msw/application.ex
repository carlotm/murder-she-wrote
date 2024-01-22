defmodule Msw.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MswWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:msw, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Msw.PubSub},
      {Finch, name: Msw.Finch},
      Msw.DB,
      MswWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Msw.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    MswWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
