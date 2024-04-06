defmodule PingServer do
  use GenServer

  def start do
    GenServer.start_link(__MODULE__, nil)
  end

  def ping(server) do
    IO.inspect("Executing GenServer on node - #{node()}")
    GenServer.call(server, :ping)
  end

  @impl GenServer
  def init(_), do: {:ok, nil}

  @impl GenServer
  def handle_call(:ping, _, state), do: {:reply, :pong, state}
end
