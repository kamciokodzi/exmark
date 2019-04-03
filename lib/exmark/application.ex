defmodule ExMark.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      ExMark.Worker
    ]

    opts = [strategy: :one_for_one, name: ExMark.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
