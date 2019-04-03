defmodule ExMarkTest do
  use ExUnit.Case
  doctest ExMark

  test "greets the world" do
    assert ExMark.hello() == :world
  end
end
