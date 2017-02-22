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
        result = url_for(location) |> HTTPoison.get |> parse_response
        case result do
            {:ok, temp} ->
                {:ok, "#{location}: #{temp}°C"}
            {:error, reason} ->
                {:error, reason}
        end
    end

    defp url_for(location) do
        location = URI.encode(location)
        "http://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{apikey()}"
    end

    defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
        body |> JSON.decode! |> compute_temperature
    end

    defp parse_response({:error, %HTTPoison.Error{id: _, reason: reason}}) do
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

    defp apikey do
        "acb2904895792f9b86627f293c081bb5"
    end
end
