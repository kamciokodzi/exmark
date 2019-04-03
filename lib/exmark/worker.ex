defmodule ExMark.Worker do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, %{request_counter: 0, times: []}}
  end

  def send_request(client, url) do
    GenServer.cast(__MODULE__, {:send_request, client, url})
  end

  def get_summary do
    GenServer.cast(__MODULE__, :get_summary)
  end

  def clear_state do
    GenServer.cast(__MODULE__, :clear_state)
  end

  def handle_cast({:send_request, client, url}, state) do
    start = System.monotonic_time(:microseconds)
    client |> Tesla.get(url)
    time_spent = System.monotonic_time(:microseconds) - start
    IO.inspect "Request no. #{state.request_counter} to #{url} took: #{time_spent} microseconds"
    state = %{request_counter: state.request_counter + 1, times: [time_spent | state.times]}
    {:noreply, state}
  end

  def handle_cast(:get_summary, []) do
    IO.inspect "State is empty."
    {:noreply, []}
  end

  def handle_cast(:get_summary, state) do
    IO.inspect state
    full_time = Enum.sum(state.times)
    avg_time = full_time/state.request_counter
    IO.inspect "Test took #{full_time} microseconds, avg time per request is: #{avg_time} microseconds."
    {:noreply, state}
  end

  def handle_cast(:clear_state, _) do
    {:noreply, %{request_counter: 0, times: []}}
  end
end
