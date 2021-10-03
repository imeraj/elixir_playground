#---
# Excerpted from "Testing Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/lmelixir for more book information.
#---
defmodule SoggyWaffle.WeatherTest do
  use ExUnit.Case, async: true
  alias SoggyWaffle.Weather

  describe "imminent_rain?/2" do
    test "returns true when it will rain in the future" do
      now = datetime(hour: 0, minute: 0, second: 0)
      one_second_from_now = datetime(hour: 0, minute: 0, second: 1)

      weather_data = [weather_struct(one_second_from_now, :rain)]

      assert Weather.imminent_rain?(weather_data, now) == true
    end

    test "returns true when it will rain less than 4 hour ahead of now" do
      now = datetime(hour: 0, minute: 0, second: 0)
      almost_4_hours_from_now = datetime(hour: 3, minute: 59, second: 59)

      weather_data = [
        weather_struct(now, :no_rain),
        weather_struct(almost_4_hours_from_now, :rain)
      ]

      assert Weather.imminent_rain?(weather_data, now) == true
    end

    test "it ignores rain more than 4 hours ahead of now" do
      now = datetime(hour: 0, minute: 0, second: 0)
      four_hours_from_now = datetime(hour: 4, minute: 0, second: 1)
      over_4_hours_from_now = datetime(hour: 4, minute: 0, second: 1)

      weather_data = [
        weather_struct(now, :no_rain),
        weather_struct(four_hours_from_now, :rain),
        weather_struct(over_4_hours_from_now, :rain)
      ]

      assert Weather.imminent_rain?(weather_data, now) == false
    end

    test "returns false when there is no rain in the future" do
      now = datetime(hour: 1, minute: 0, second: 0)
      second_ago = datetime(hour: 0, minute: 59, second: 59)
      second_ahead = datetime(hour: 1, minute: 0, second: 1)

      weather_data = [
        weather_struct(second_ago, :rain),
        weather_struct(second_ahead, :no_rain)
      ]

      assert Weather.imminent_rain?(weather_data, now) == false
    end

    defp weather_struct(datetime, condition) do
      %Weather{
        datetime: datetime,
        rain?: condition == :rain
      }
    end

    defp datetime(hour: hour, minute: minute, second: second) do
      %DateTime{
        calendar: Calendar.ISO,
        day: 1,
        hour: hour,
        microsecond: {0, 6},
        minute: minute,
        month: 1,
        second: second,
        std_offset: 0,
        time_zone: "Etc/UTC",
        utc_offset: 0,
        year: 2020,
        zone_abbr: "UTC"
      }
    end
  end
end
