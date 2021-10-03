#---
# Excerpted from "Testing Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/lmelixir for more book information.
#---
defmodule SoggyWaffle.WeatherAPI.ResponseParser do
  alias SoggyWaffle.Weather

  @thunderstorm_ids [200, 201, 202, 210, 211, 212, 221, 230, 231, 232]
  @drizzle_ids [300, 301, 302, 310, 311, 312, 313, 314, 321]
  @rain_ids [500, 501, 502, 503, 504, 511, 520, 521, 522, 531]
  @all_rain_ids @thunderstorm_ids ++ @drizzle_ids ++ @rain_ids

  @spec parse_response(Weather.t()) ::
          {:ok, list(Weather.t())} | {:error, atom()}
  def parse_response(response) do
    results = response["list"]

    Enum.reduce_while(results, {:ok, []}, fn
      %{"dt" => datetime, "weather" => [%{"id" => condition_id}]},
      {:ok, weather_list} ->
        # possible weather codes: https://openweathermap.org/weather-conditions

        new_weather = %Weather{
          datetime: DateTime.from_unix!(datetime),
          rain?: condition_id in @all_rain_ids
        }

        {:cont, {:ok, [new_weather | weather_list]}}

      _anything_else, _acc ->
        {:halt, {:error, :response_format_invalid}}
    end)
  end
end
