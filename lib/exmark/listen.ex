defmodule Listen do
  def call do
    receive do
      {:send_request, client, url} ->
        ExMark.Worker.send_request(client, url)
        # IO.inspect "hehe"
    end

    call()
  end
end
