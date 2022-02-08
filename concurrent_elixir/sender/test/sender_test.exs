defmodule SenderTest do
  use ExUnit.Case
  doctest Sender

  test "greets the world" do
    assert Sender.hello() == :world
  end
end
