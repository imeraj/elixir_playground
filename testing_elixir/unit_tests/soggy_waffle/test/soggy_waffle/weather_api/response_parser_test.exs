defmodule SoggyWaffle.WeatherAPI.ResponseParserTest do
  use ExUnit.Case
  alias SoggyWaffle.WeatherAPI.ResponseParser
  alias SoggyWaffle.Weather

  setup_all do
    response_as_map =
      File.read!("test/support/weather_api_response.json")
      |> Jason.decode!()

    %{weather_data: response_as_map}
  end

  describe "parse_response/1" do
    test "success: accepts a valid response, returns a list of structs", %{weather_data: weather_data} do
      assert {:ok, parsed_response} = ResponseParser.parse_response(weather_data)

      for weather_record <- parsed_response do
        assert match?(%Weather{datetime: %DateTime{}, rain?: _rain}, weather_record)
        assert is_boolean(weather_record.rain?)
      end
    end
  end
end