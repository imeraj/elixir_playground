#---
# Excerpted from "Testing Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/lmelixir for more book information.
#---
defmodule RollingAverage do
  use GenServer

  defstruct [:size, :measurements]

  # Public API

  def start_link(max_measurements) do
    GenServer.start_link(__MODULE__, max_measurements)
  end

  def add_element(pid, element) do
    GenServer.cast(pid, {:add_element, element})
  end

  def average(pid) do
    GenServer.call(pid, :average)
  end

  @impl GenServer
  def init(max_measurements) do
    {:ok, %__MODULE__{size: max_measurements, measurements: []}}
  end

  @impl GenServer
  def handle_call(:average, _from, state) do
    {:reply, Enum.sum(state.measurements) / length(state.measurements), state}
  end

  @impl GenServer
  def handle_cast({:add_element, new_element}, state) do
    measurements =
      if length(state.measurements) < state.size do
        [new_element | state.measurements]
      else
        without_oldest = Enum.drop(state.measurements, -1)
        [new_element | without_oldest]
      end

    {:noreply, %__MODULE__{state | measurements: measurements}}
  end
end
