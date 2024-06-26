defmodule Pooly.Worker do
	@moduledoc false

	use GenServer

	def start_link(_) do
		GenServer.start_link(__MODULE__, :ok, [])
	end

	def init(:ok) do
		{:ok, %{}}
	end

	def stop(pid) do
		GenServer.call(pid, :stop)
	end

	def handle_call(:stop, _from, state) do
		{:stop, :normal, :ok, state}
	end
end
