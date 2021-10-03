#---
# Excerpted from "Testing Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/lmelixir for more book information.
#---
defmodule SoggyWaffle.WeatherApi.Test do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  alias SoggyWaffle.WeatherAPI

  describe "get_forecast/1" do
    test "success: it returns a map paylod in the expected shape" do
      use_cassette "weather_api/get_forecast/success" do
        assert {:ok, %{"list" => data}} = WeatherAPI.get_forecast("Denver")

        for record <- data do
          assert match?(%{"dt" => _, "weather" => [%{"main" => _}]}, record)
        end
      end
    end

    test "error: it returns an error tuple when the city can't be found" do
      use_cassette "weather_api/get_forecast/not_found" do
        assert {:error, {:status, 404}} =
                 WeatherAPI.get_forecast("Denver, CO")
      end
    end

    test "error: it returns an error tuple when the it can't connect to the service" do
      use_cassette "weather_api/get_forecast/no_internet" do
        assert {:error, %HTTPoison.Error{}} =
                 WeatherAPI.get_forecast("Denver, CO")
      end
    end
  end
end
