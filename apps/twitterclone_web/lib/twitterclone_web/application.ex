defmodule TwittercloneWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      TwittercloneWeb.Telemetry,
      # Start the Endpoint (http/https)
      TwittercloneWeb.Endpoint,
      TwittercloneWeb.Presence,
      # Start a worker by calling: TwittercloneWeb.Worker.start_link(arg)
      # {TwittercloneWeb.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TwittercloneWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TwittercloneWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
