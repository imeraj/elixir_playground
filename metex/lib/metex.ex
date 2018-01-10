defmodule Metex.Worker do
    def loop do
        receive do
            {from, location} ->
                send(from, temperature_of(location))
            _ ->
                IO.puts "don't know how to process this message"
        end
        loop()
    end

    defp temperature_of(location) do
        result = url_for(location)
                 |> HTTPoison.get
                 |> parse_response
        case result do
            {:ok, temp} ->
                {:ok, "#{location}: #{temp}°C"}
	          {:ok, code, msg} ->
		            {:ok, "#{msg}: #{code}"}
	          {:error, reason} ->
              {:ok, reason}
        end
    end

    defp url_for(location) do
        location = URI.encode(location)
        "http://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{apikey()}"
    end

    defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
        body
        |> JSON.decode!
        |> compute_temperature
    end

    defp parse_response({:ok, %HTTPoison.Response{body: _, status_code: status_code}}) do
      {:ok, status_code, "API call failed!"}
    end

    defp parse_response({:error, %HTTPoison.Error{id: _, reason: reason}}) do
      {:error, reason}
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

    defp apikey do
      Application.fetch_env!(:metex, :apiKey)
    end
end
