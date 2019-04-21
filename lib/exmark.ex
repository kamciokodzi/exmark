defmodule ExMark do
  def single_request(x, url) do
    start = System.monotonic_time(:microseconds)
    url = String.to_charlist(url)
    :httpc.request(:get, {url, []}, [], [])
    time_spent = (System.monotonic_time(:microseconds) - start)/1000
    IO.inspect "#{x} request took: #{Float.round(time_spent, 3)} [ms]."
    time_spent
  end

  def request_concurently(_, 0), do: []
  def request_concurently(url, c) do
    tasks = for x <- 1..c do
      Task.async(fn ->
        single_request(x, url)
      end)
    end

    times = Enum.map(tasks, &Task.await(&1))
    sum = times |> Enum.sum()
    avg = sum/c

    IO.inspect "Chunk of #{c} requests completed in #{Float.round(sum, 3)} [ms] with average of #{Float.round(avg, 3)} [ms]."
    %{sum: sum, avg: avg, requests: c, times: times}
  end

  def send_request(url, n, c \\ 1) do
    start = System.monotonic_time(:microseconds)

    chunks = div(n,c)
    rest = n - chunks*c

    result = for _ <- 1..chunks do
      request_concurently(url, c)
    end

    r = request_concurently(url, rest)

    time_spent = (System.monotonic_time(:microseconds) - start)/1000000

    result
    |> parse_rest(r)
    |> summarize_results(c, time_spent)
  end

  defp parse_rest(result, []), do: result
  defp parse_rest(result, rest), do: result ++ [rest]

  def summarize_results(results, c, time) do
    sum = Enum.map(results, & &1.sum) |> Enum.sum()
    times = Enum.map(results, & &1.times) |> List.flatten()
    sum_of_requests = Enum.map(results, & &1.requests) |> Enum.sum()
    avg = sum/sum_of_requests
    req_per_sec = (c * 1000)/avg

    IO.inspect "============ SUMMARY REPORT ==============="
    IO.inspect "Concurrency Level:         #{c}"
    IO.inspect "Complete requests:         #{sum_of_requests}"
    IO.inspect "Time taken for tests:      #{Float.round(time, 3)} seconds"
    IO.inspect "Requests per second:       #{Float.round(req_per_sec, 3)} [#/sec] (mean)"
    IO.inspect "Time per request:          #{Float.round(avg, 3)} [ms] (mean)"
    IO.inspect "Time per request:          #{Float.round(avg/c, 3)} [ms] (mean, across all concurrent requests)"
    IO.inspect "Shortest request:          #{Enum.min(times)} [ms]"
    IO.inspect "Longest request:           #{Enum.max(times)} [ms]"

    times
    |> Enum.sort()
    |> percentages()

    "=============== END ==================="
  end

  defp percentages(times) do
    len = length(times)
    percent_50 = div(len, 2) - 1
    percent_66 = len - div(len, 3) - 1
    percent_75 = len - div(len, 4) - 1
    percent_80 = len - div(len, 5) - 1
    percent_90 = len - div(len, 10) - 1
    percent_95 = len - 5 * div(len, 100) - 1
    percent_99 = len - div(len, 100) - 1

    IO.inspect "50% served within: #{Enum.at(times, percent_50)}"
    IO.inspect "66% served within: #{Enum.at(times, percent_66)}"
    IO.inspect "75% served within: #{Enum.at(times, percent_75)}"
    IO.inspect "80% served within: #{Enum.at(times, percent_80)}"
    IO.inspect "90% served within: #{Enum.at(times, percent_90)}"
    IO.inspect "95% served within: #{Enum.at(times, percent_95)}"
    IO.inspect "99% served within: #{Enum.at(times, percent_99)}"
    IO.inspect "100% served within #{Enum.max(times)} (longest request)"

  end
end
