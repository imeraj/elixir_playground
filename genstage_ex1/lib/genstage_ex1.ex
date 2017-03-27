defmodule GenstageEx1 do
  @moduledoc """
  Simple example using GenStage pipeline
  """

  @doc """
  Producer stage - create events based on demand from consumer
  """
  defmodule Map do
    use GenStage

    def init(url) do
      {:producer, url}
    end

    def handle_demand(demand, url) when demand > 0 do
      events = List.duplicate(url, demand)
      {:noreply, events, url}
    end
  end


  defmodule Ticker do
    use GenStage

    def init(sleeping_time) do
      {:consumer, sleeping_time}
    end

    def handle_events(events, _from, sleeping_time) do
      IO.inspect(events)
      Process.sleep(sleeping_time)
      {:noreply, [], sleeping_time}
    end
  end

  {:ok, map} = GenStage.start_link(Map, "http://feeds.citibikenyc.com/stations/stations.json")
  {:ok, ticker} = GenStage.start_link(Ticker, 5_000)

  GenStage.sync_subscribe(ticker, to: map, max_demand: 1)

  Process.sleep(:infinity)
end
