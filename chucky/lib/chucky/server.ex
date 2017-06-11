defmodule Chucky.Server do
  use GenServer
  require Logger

  @moduledoc false

  @on_load :load_check

  # API
  def start_link do
    GenServer.start_link(__MODULE__, [], name: {:global, __MODULE__})
  end

  def fact do
    GenServer.call({:global, __MODULE__}, :fact)
  end

  # Callbacks
  def init([]) do
    :rand.uniform()
    facts = "facts.txt"
            |> File.read!
            |> String.split("\n", trim: true)
    {:ok, facts}
  end

  def handle_call(:fact, _from, facts) do
    random_fact = facts
           |> Enum.shuffle
           |> List.first

    {:reply, random_fact, facts}
  end

  def load_check do
    Logger.debug "Module #{__MODULE__} is loaded."
  end

end