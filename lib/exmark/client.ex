defmodule ExMark.Client do
  use Tesla

  def build(headers \\ []) do
    middleware = [
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, build_headers(headers)}
    ]

    Tesla.client(middleware)
  end

  defp build_headers(headers) do
    Enum.map(headers, fn {key, value} ->
      {to_string(key), to_string(value)}
    end)
  end
end
