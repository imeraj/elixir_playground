#---
# Excerpted from "Testing Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/lmelixir for more book information.
#---

ExUnit.start

defmodule RollingAverageTest do
  use ExUnit.Case

  describe "start_link/1" do
    test "accepts a measurement count of start" do
      max_measurements = 3.0
      assert {:ok, _pid} = RollingAverage.start_link(max_measurements)
    end
  end

  describe "add_element/2" do
    test "adding an element to a full list rolls a value" do
      max_measurements = Enum.random(3..10)
      {:ok, pid} = RollingAverage.start_link(max_measurements)

      for _ <- 1..max_measurements do
        RollingAverage.add_element(pid, 4)
      end

      assert %{size: ^max_measurements, measurements: measurements} =
        :sys.get_state(pid)

      expected_measurements = List.duplicate(4, max_measurements)
      assert measurements == expected_measurements

      RollingAverage.add_element(pid, 1)

      assert %{size: ^max_measurements, measurements: measurements} =
        :sys.get_state(pid)

      expected_measurements = [1 | List.duplicate(4, max_measurements - 1)]
      assert measurements == expected_measurements
    end
  end

  describe "average/1" do
    test "it returns the average for the elements" do
      max_measurements = 2
      {:ok, pid} = RollingAverage.start_link(max_measurements)

      RollingAverage.add_element(pid, 5)
      RollingAverage.add_element(pid, 6)
      assert RollingAverage.average(pid) == 5.5

      RollingAverage.add_element(pid, 7)
      assert RollingAverage.average(pid) == 6.5
    end
  end

end
