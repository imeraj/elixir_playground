defmodule Scraper do
  @moduledoc """
  Documentation for `Scraper`.
  """

  def work() do
    1..5
    |> Enum.random()
    |> :timer.seconds()
    |> Process.sleep()
  end
end
