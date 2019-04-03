defmodule ExMark do
  def test(url, headers \\ []) do
    client = ExMark.Client.build(headers)

    start = System.monotonic_time(:microseconds)
    tasks = for x <- 1..100 do
      Task.async(fn -> ExMark.Worker.send_request(client, url) end)
      # spawn(ExMark.Worker, :send_request, [client, url])
    end

    Task.await(List.last(tasks))

    ExMark.Worker.get_summary()

    time_spent = System.monotonic_time(:microseconds) - start
    IO.inspect "Spawned 100 processes in #{time_spent} microseconds."
  end

  def test_synch(url) do
    client = ExMark.Client.build()

    start = System.monotonic_time(:microseconds)
    for x <- 1..100 do
      ExMark.Worker.send_request(client,url)
    end

    ExMark.Worker.get_summary()

    time_spent = System.monotonic_time(:microseconds) - start
    IO.inspect time_spent
  end

  def test2(url, headers \\ []) do
    client = ExMark.Client.build(headers)

    pids = for x <- 1..100 do
      spawn(Listen, :call, [])
    end

    tasks = for pid <- pids do
      Task.async(fn ->
        send pid, {:send_request, client, url}
      end)
    end
  end
end
