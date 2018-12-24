defmodule MetexGenserver.Worker do
    use GenServer

    @name MW

    defp apikey do
	    "acb2904895792f9b86627f293c081bb5"
    end

    ## Client API
    def start_link(options \\ []) do
        GenServer.start_link(__MODULE__, :ok, options ++ [name: @name])
    end

    def get_temperature(location) do
        GenServer.call(@name, {:location, location})
    end

    def reset_stats do
        GenServer.call(@name, :reset_stats)
    end

    def get_stats do
        GenServer.call(@name, :get_stats)
    end

    def stop do
        GenServer.cast(@name, :stop)
    end

    def terminate(reason, _stats) do
	    IO.puts "server terminated because of #{inspect reason} reason"
	    :ok
    end

    ## Helper Functions
    defp temperature_of(location) do
        result = url_for(location)
                |> HTTPoison.get
                |> parse_response
    end

    defp url_for(location) do
        location = URI.encode(location)
        "http://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{apikey()}"
    end

    defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
        body |> JSON.decode! |> compute_temperature
    end

    defp parse_response({:ok, %HTTPoison.Response{body: _, status_code: _status_code}}) do
         {:error, "City not found!"}
    end

    defp compute_temperature(json) do
        try do
            temp = (json["main"]["temp"] - 273.15)
                   |> Float.round(1)
            {:ok, temp}
        rescue
            _ -> :error
        end
    end

    defp update_stats(old_stats, location) do
        case Map.has_key?(old_stats, location) do
            true ->
                Map.update!(old_stats, location, &(&1 + 1))
            false ->
                Map.put_new(old_stats, location, 1)
        end
    end

    ## Server Callbacks
    def init(:ok) do
	    {:ok, %{}}
    end

    def handle_call({:location, location}, _from, stats) do
	    case temperature_of(location) do
		    {:ok, temp} ->
			    new_stats = update_stats(stats, location)
			    {:reply, "#{temp}°C", new_stats}
        {:error, message} ->
            {:reply, message, stats}
		    _ ->
			    {:reply, :error, stats}
	    end
    end

    def handle_call(:get_stats, _from, stats) do
	    {:reply, stats, stats}
    end

    def handle_call(:reset_stats, _from, _stats) do
	    {:reply, %{}, %{}}
    end

    def handle_cast(:stop, stats) do
	    {:stop, :normal, stats}
    end

    def handle_info(msg, stats) do
	    IO.puts "received #{inspect msg}"
	    {:noreply, stats}
    end
end
