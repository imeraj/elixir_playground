defmodule Flowexample do
  @moduledoc """
  Count words in a file in parellel with flow
  """
  def wordcount() do
    File.stream!("/Users/sekailabbd/Development/Elixir/Elixir_Playground/flowexample/mix.exs")
    |> Flow.from_enumerable()
    |> Flow.flat_map(&String.split(&1, " "))
    |> Flow.map(&String.replace(&1, "\n", ""))
    |> Flow.partition
    |> Flow.reduce(fn -> %{} end, fn word, acc ->
            Map.update(acc, word, 1, &(&1 + 1))
        end)
    |> Enum.to_list()
  end
end
