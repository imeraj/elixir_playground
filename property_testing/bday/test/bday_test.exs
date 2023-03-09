defmodule BdayTest do
  use ExUnit.Case
  doctest Bday

  test "greets the world" do
    assert Bday.hello() == :world
  end
end
