defmodule SoggyWaffle.WeatherAPI.ResponseParserTest do
  use ExUnit.Case
  alias SoggyWaffle.WeatherAPI.ResponseParser
  alias SoggyWaffle.Weather

  @thunderstorm_ids {
    "thunderstorm",
    [200, 201, 202, 210, 211, 212, 221, 230, 231, 232]
  }
  @drizzle_ids {"drizzle", [300, 301, 302, 310, 311, 312, 313, 314, 321]}
  @rain_ids {"rain", [500, 501, 502, 503, 504, 511, 520, 521, 522, 531]}

  setup_all do
    response_as_map =
      File.read!("test/support/weather_api_response.json")
      |> Jason.decode!()

    %{weather_data: response_as_map}
  end

  describe "parse_response/1" do
    test "success: accepts a valid response, returns a list of structs", %{
      weather_data: weather_data
    } do
      assert {:ok, parsed_response} =
               ResponseParser.parse_response(weather_data)

      for weather_record <- parsed_response do
        assert match?(
                 %Weather{datetime: %DateTime{}, rain?: _rain},
                 weather_record
               )

        assert is_boolean(weather_record.rain?)
      end
    end
  end

  for {condition, ids} <- [@thunderstorm_ids, @drizzle_ids, @rain_ids] do
    test "success: recognizes #{condition} as a rainy condition" do
      now_unix = DateTime.utc_now() |> DateTime.to_unix()

      for id <- unquote(ids) do
        record = %{"dt" => now_unix, "weather" => [%{"id" => id}]}

        assert {:ok, [weather_struct]} =
                 ResponseParser.parse_response(%{"list" => [record]})

        assert weather_struct.rain? == true,
               "Expected weather id (#{id}) to be a rain condition"
      end
    end
  end

  test "success: returns rain? false for any other id codes" do
    {_, thunderstorm_ids} = @thunderstorm_ids
    {_, drizzle_ids} = @drizzle_ids
    {_, rain_ids} = @rain_ids

    all_rain_ids = thunderstorm_ids ++ drizzle_ids ++ rain_ids
    now_unix = DateTime.utc_now() |> DateTime.to_unix()

    for id <- 100..900, id not in all_rain_ids do
      record = %{"dt" => now_unix, "weather" => [%{"id" => id}]}

      assert {:ok, [weather_struct]} =
               ResponseParser.parse_response(%{"list" => [record]})

      assert weather_struct.rain? == false,
             "Expected weather id (#{id}) to NOT be a rain condition"
    end
  end

  test "error: returns error if weather data is malformed" do
    malformed_day = %{
      "dt" => DateTime.utc_now() |> DateTime.to_unix(),
      "weather" => [
        %{
          "wrong_key" => 1
        }
      ]
    }

    almost_correct_response = %{"list" => [malformed_day]}

    assert {:error, :response_format_invalid} =
             ResponseParser.parse_response(almost_correct_response)
  end

  test "error: returns error if timestamp is missing" do
    malformed_day = %{
      "datetime" => DateTime.utc_now() |> DateTime.to_unix(),
      "weather" => [
        %{
          "main" => 1
        }
      ]
    }

    almost_correct_response = %{"list" => [malformed_day]}

    assert {:error, :response_format_invalid} =
             ResponseParser.parse_response(almost_correct_response)
  end
end
