defmodule SoggyWaffle.WeatherAPI.ResponseParserTest do
  use ExUnit.Case
  alias SoggyWaffle.WeatherAPI.ResponseParser
  alias SoggyWaffle.Weather

  describe "parse_response/1" do
    test "success: accepts a valid response, returns a list of structs" do
      api_response = %{
        "list" => [
          %{"dt" => 1_574_359_200, "weather" => [%{"id" => 600}]},
          %{"dt" => 1_574_359_900, "weather" => [%{"id" => 299}]}
        ]
      }

      assert {:ok, parsed_response} = ResponseParser.parse_response(api_response)

      for weather_record <- parsed_response do
        assert match?(%Weather{datetime: %DateTime{}, rain?: _rain}, weather_record)
        assert is_boolean(weather_record.rain?)
      end

    end
  end
end