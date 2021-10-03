#---
# Excerpted from "Testing Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/lmelixir for more book information.
#---
defmodule SoggyWaffle.WeatherAPI do
  @spec get_forecast(String.t()) :: {:ok, map()} | {:error, reason :: term()}
  def get_forecast(city) when is_binary(city) do
    app_id = "replace me"
    query_params = URI.encode_query(%{"q" => city, "APPID" => app_id})
    url = "https://api.openweathermap.org/data/2.5/forecast?" <> query_params

    case HTTPoison.get(url) do
      {:ok,
       %HTTPoison.Response{status_code: 200, body: body, headers: _headers}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, {:status, status_code}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
