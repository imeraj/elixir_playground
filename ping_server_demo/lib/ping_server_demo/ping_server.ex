defmodule PingServer do
  use GenServer

  def start do
    GenServer.start_link(__MODULE__, nil, name: {:global, __MODULE__})
  end

  def ping do
    IO.inspect("Executing Genserver on node - #{node()}")
    GenServer.call({:global, __MODULE__}, :ping)
  end

  @impl GenServer
  def init(_), do: {:ok, nil}

  @impl GenServer
  def handle_call(:ping, _, state), do:  {:reply, :pong, state}
end
