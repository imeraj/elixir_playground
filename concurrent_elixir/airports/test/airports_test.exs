defmodule AirportsTest do
  use ExUnit.Case
  doctest Airports

  test "greets the world" do
    assert Airports.hello() == :world
  end
end
