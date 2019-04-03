defmodule Listen do
  def call do
    receive do
      {:send_request, :a} ->
        # start = System.monotonic_time(:milliseconds)
        t1 = :erlang.timestamp
        :httpc.request(:get, {'http://google.com', []}, [], [])
        t2 = :erlang.timestamp
        time_spent = :timer.now_diff(t2,t1) / 1000
        # time_spent = System.monotonic_time(:milliseconds) - start
        IO.inspect time_spent
    end

    call()
  end
end
