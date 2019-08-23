defmodule Extop do
  use GenServer, start: {__MODULE__, :start_link, []}

  def start_link(), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def load(), do: get_value(:current_load)

  defdelegate subscribe_to_stats(), to: Extop.Stats, as: :subscribe

  def change_load(desired_load) do
    current_load = load()
    set_value(:current_load, desired_load)

    if desired_load > current_load do
      (current_load + 1)..desired_load
      |> Stream.zip(Stream.cycle(all_nodes()))
      |> Enum.each(&start_worker/1)
    else
      fn ->
        :timer.sleep(1500)
        Enum.each(Process.list(), &:erlang.garbage_collect(&1, type: :major))
      end
      |> Task.async()
      |> Task.await(:infinity)
    end
  end

  def set_failure_rate(desired_failure_rate), do: set_value(:failure_rate, desired_failure_rate)

  def failure_rate(), do: get_value(:failure_rate)

  def join_worker(), do: :ets.update_counter(__MODULE__, :workers_count, 1)

  def leave_worker(), do: :ets.update_counter(__MODULE__, :workers_count, -1)

  def workers_count(), do: get_value(:workers_count)

  def change_schedulers(schedulers) do
    :erlang.system_flag(:schedulers_online, schedulers)
    :erlang.system_flag(:dirty_cpu_schedulers_online, schedulers)
  end

  def init(_) do
    :ets.new(__MODULE__, [:named_table, :public, read_concurrency: true, write_concurrency: true])
    set_value(:workers_count, 0)
    set_value(:current_load, 0)
    set_value(:failure_rate, 0)
    {:ok, nil}
  end

  defp get_value(key) do
    [{^key, value}] = :ets.lookup(__MODULE__, key)
    value
  end

  defp set_value(key, value),
    do: :rpc.multicall(all_nodes(), :ets, :insert, [__MODULE__, {key, value}], :infinity)

  defp all_nodes(), do: Node.list([:this, :visible])

  defp start_worker({worker_id, target_node}) do
    if target_node == node() do
      Extop.Workers.start_worker(worker_id)
    else
      :rpc.cast(target_node, Extop.Workers, :start_worker, [worker_id])
    end
  end

  def top(time \\ :timer.seconds(1)) do
    wall_times = Extop.SchedulerMonitor.wall_times()
    initial_processes = processes()

    Process.sleep(time)

    final_processes =
      Enum.map(
        processes(),
        fn {pid, reds} ->
          prev_reds = Map.get(initial_processes, pid, 0)
          %{pid: pid, reds: reds - prev_reds}
        end
      )

    schedulers_usage =
      Extop.SchedulerMonitor.usage(wall_times) / :erlang.system_info(:schedulers_online)

    total_reds_delta = final_processes |> Stream.map(& &1.reds) |> Enum.sum()

    final_processes
    |> Enum.sort_by(& &1.reds, &>=/2)
    |> Stream.take(10)
    |> Enum.map(&%{pid: &1.pid, cpu: round(schedulers_usage * 100 * &1.reds / total_reds_delta)})
  end

  defp processes() do
    for {pid, {:reductions, reds}} <-
          Stream.map(Process.list(), &{&1, Process.info(&1, :reductions)}),
        into: %{},
        do: {pid, reds}
  end

  def trace(pid) do
    Task.async(fn ->
      :erlang.trace(pid, true, [:call])

      try do
        :erlang.trace(pid, true, [:call])
      rescue
        ArgumentError ->
          []
      else
        _ ->
          :erlang.trace_pattern({:_, :_, :_}, true, [:local])
          Process.send_after(self(), :stop_trace, :timer.seconds(1))

          fn ->
            receive do
              {:trace, ^pid, :call, {mod, fun, args}} -> {mod, fun, args}
              :stop_trace -> :stop_trace
            end
          end
          |> Stream.repeatedly()
          |> Stream.take(50)
          |> Enum.take_while(&(&1 != :stop_trace))
      end
    end)
    |> Task.await()
  end
end
