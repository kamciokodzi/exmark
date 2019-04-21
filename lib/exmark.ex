defmodule ExMark do
  def single_request(x, url) do
    start = System.monotonic_time(:microseconds)
    url = String.to_charlist(url)
    :httpc.request(:get, {url, []}, [], [])
    time_spent = (System.monotonic_time(:microseconds) - start)/1000000
    IO.inspect "#{x} request took: #{time_spent} seconds"
    time_spent
  end

  def request_concurently(url, c) do
    tasks = for x <- 1..c do
      Task.async(fn ->
        single_request(x, url)
      end)
    end

    sum = Enum.map(tasks, &Task.await(&1))
    |> Enum.sum()
    avg = sum/c

    IO.inspect "Chunk of #{c} requests completed in #{sum} seconds with average of #{avg}"
    %{sum: sum, avg: avg, requests: c}
  end

  def send_request(url, n, c \\ 1) do
    for x <- 1..n do
      request_concurently(url, c)
    end
  end
end
