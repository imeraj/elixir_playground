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
      HTTPoison.start()
      {:producer, url}
    end

    def handle_demand(demand, url) when demand > 0 do
      events = List.duplicate(url, demand)
      {:noreply, events, url}
    end
  end

  defmodule GetHTTP do
    use GenStage

    def init(:ok) do
      {:producer_consumer, :ok}
    end

    def handle_events(events, _from, _state) do
     events = Enum.map(events, &retrieve_as_json(&1))
       {:noreply, events, :ok}
    end

    defp retrieve_as_json(url) do
     {:ok, %HTTPoison.Response{body: body}} = HTTPoison.get(url)
     Poison.Parser.parse!(body)
    end
  end

  defmodule Unpack do
    use GenStage
    def init(element) do
      {:producer_consumer, element}
    end

    def handle_events(events, _from, element) do
      events = Enum.map(events, & &1[element])
      {:noreply, events, element}
    end
  end

  defmodule Filter do
   use GenStage
   def init({filter, filter_value}) do
     {:producer_consumer, {filter, filter_value}}
   end
   def handle_events(events, _from, {filter, filter_value} = state) do
     events = Enum.map(events,
                          fn stations ->
                            Enum.filter(stations, & &1[filter] == filter_value)
                          end)
     {:noreply, events, state}
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
  {:ok, getHTTP} = GenStage.start_link(GetHTTP, :ok)
  {:ok, unpack}  = GenStage.start_link(Unpack, "stationBeanList")
  {:ok, filter}  = GenStage.start_link(Filter, {"stationName", "W 14 St & The High Line"})
  {:ok, ticker} = GenStage.start_link(Ticker, 5_000)

  GenStage.sync_subscribe(ticker, to: filter)
  GenStage.sync_subscribe(filter, to: unpack)
  GenStage.sync_subscribe(unpack, to: getHTTP)
  GenStage.sync_subscribe(getHTTP, to: map,max_demand: 1)

  Process.sleep(:infinity)
end
