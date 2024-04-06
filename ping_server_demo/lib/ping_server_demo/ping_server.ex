defmodule PingServer do
  use GenServer

  def start do
    GenServer.start_link(__MODULE__, nil, name: via_tuple())
  end

  def ping do
    IO.inspect("Executing Genserver on node - #{node()}")
    GenServer.call(via_tuple(), :ping)
  end

  @impl GenServer
  def init(_), do: {:ok, nil}

  @impl GenServer
  def handle_call(:ping, _, state), do: {:reply, :pong, state}

  defp via_tuple, do: PingServerRegistry.via_tuple(__MODULE__)
end
