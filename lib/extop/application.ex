defmodule Extop.Application do
  use Application

  def start(_type, _args) do
    children = [
      Extop.Stats,
      Extop.SchedulerMonitor,
      Extop.Workers,
      Extop
    ]

    opts = [strategy: :one_for_one, name: Extop.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
