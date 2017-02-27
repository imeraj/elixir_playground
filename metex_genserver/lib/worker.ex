defmodule MetexGenserver.Worker do
    use GenServer

    ## Client API
    def start_link(options \\ []) do
        GenServer.start_link(__MODULE__, :ok, options)
    end

    def get_temperature(pid, location) do
        GenServer.call(pid, {:location, location})
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
            _ ->
                {:reply, :error, stats}
        end
    end

    ## Helper Functions
    defp temperature_of(location) do
        url_for(location) |> HTTPoison.get |> parse_response
    end

    defp url_for(location) do
        location = URI.encode(location)
        "http://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{apikey()}"
    end

    defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
        body |> JSON.decode! |> compute_temperature
    end

    defp parse_response({:error, %HTTPoison.Error{id: _, reason: reason}}) do
        IO.puts "error here"
         {:error, reason}
    end

    defp compute_temperature(json) do
        try do
            temp = (json["main"]["temp"] - 273.15) |> Float.round(1)
            {:ok, temp}
        rescue
            _ -> :error
        end
    end

    def update_stats(old_stats, location) do
        case Map.has_key?(old_stats, location) do
            true ->
                Map.update!(old_stats, location, &(&1 + 1))
            false ->
                Map.put_new(old_stats, location, 1)
        end
    end

    def apikey do
        "acb2904895792f9b86627f293c081bb5"
    end
end
