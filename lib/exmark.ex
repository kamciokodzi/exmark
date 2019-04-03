defmodule ExMark do
  def test(url, headers \\ []) do
    client = ExMark.Client.build(headers)

    start = System.monotonic_time(:microseconds)
    for x <- 1..100 do
      spawn(ExMark.Worker, :send_request, [client, url])
    end
    time_spent = System.monotonic_time(:microseconds) - start
    IO.inspect "Spawned 100 processes in #{time_spent} microseconds."


    ExMark.Worker.get_summary()
  end

  def test_synch(url) do
    client = ExMark.Client.build()

    start = System.monotonic_time(:microseconds)
    for x <- 1..100 do
      ExMark.Worker.send_request(client,url)
    end
    time_spent = System.monotonic_time(:microseconds) - start
    IO.inspect time_spent
  end
end
