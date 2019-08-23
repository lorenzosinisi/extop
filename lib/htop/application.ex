defmodule Htop.Application do
  use Application

  def start(_type, _args) do
    children = [
      Htop.Stats,
      Htop.SchedulerMonitor,
      Htop.Workers,
      Htop
    ]

    opts = [strategy: :one_for_one, name: Htop.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
