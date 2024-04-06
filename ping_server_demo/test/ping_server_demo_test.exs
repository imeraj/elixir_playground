defmodule PingServerDemoTest do
  use ExUnit.Case
  doctest PingServerDemo

  test "greets the world" do
    assert PingServerDemo.hello() == :world
  end
end
