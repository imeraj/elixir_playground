#---
# Excerpted from "Testing Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/lmelixir for more book information.
#---
defmodule SoggyWaffle.Weather do
  @type t :: %__MODULE__{}

  defstruct [:datetime, :rain?]

  @spec imminent_rain?([t()], DateTime.t()) :: boolean()
  def imminent_rain?(weather_data, now \\ DateTime.utc_now()) do  
    Enum.any?(weather_data, fn
      %__MODULE__{rain?: true} = weather ->
        in_next_4_hours?(now, weather.datetime)

      _ ->
        false
    end)
  end

  defp in_next_4_hours?(now, weather_datetime) do
    four_hours_from_now =
      DateTime.add(now, _4_hours_in_seconds = 4 * 60 * 60)

    DateTime.compare(weather_datetime, now) in [:gt, :eq] and
      DateTime.compare(weather_datetime, four_hours_from_now) in [:lt, :eq]
  end
end
