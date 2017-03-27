import IEx

defmodule GenstageEx2 do
  @moduledoc """
  Genstage example using Dispatcher
  """

  defmodule Splitter do
    use GenStage

    def init(_) do
        {:producer_consumer, %{},
                dispatcher: {GenStage.PartitionDispatcher,
                                                partitions: 0..1,
                                               hash: &split/1 }}
    end

    defp split(event) do
        {event, rem(event, 2)}
    end

    def handle_events(events, _from, state) do
        {:noreply, events, state}
    end
  end

  defmodule Ticker do
     use GenStage

     def init(state) do
         {:consumer, state}
     end

     def handle_events(events, _from, {sleeping_time, tag} = state) do
         IO.puts "Ticker(#{tag}) events: #{inspect events, charlists: :as_lists}"
         Process.sleep(sleeping_time)
         {:noreply, [], state}
     end
  end

  {:ok, inport} = GenStage.from_enumerable(1..10)
  {:ok, splitter} = GenStage.start_link(Splitter, 0)
  {:ok, evens}    = GenStage.start_link(Ticker, {2_000, :evens})
  {:ok, odds}     = GenStage.start_link(Ticker, {2_000, :odds})

  GenStage.sync_subscribe(evens, to: splitter, partition: 0, max_demand: 1)
  GenStage.sync_subscribe(odds, to: splitter, partition: 1, max_demand: 1)
  GenStage.sync_subscribe(splitter, to: inport, max_demand: 1)

  Process.sleep(:infinity)
end
