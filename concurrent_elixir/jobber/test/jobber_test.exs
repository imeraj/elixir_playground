defmodule JobberTest do
  use ExUnit.Case
  doctest Jobber

  test "greets the world" do
    assert Jobber.hello() == :world
  end
end
