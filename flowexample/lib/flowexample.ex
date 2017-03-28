defmodule Flowexample do
  @moduledoc """
  Count words in a file in parellel with flow
  """
  def wordcount do
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

  @doc """
  Input: CGGACTCGACAGATGTGAAGAACGACAATGTGAAGACTCGACACGACAGAGTGAAGAGAAGAGGAAACATTGTAA

  Parameters: Find the 5-mers that appear at least 4 times in a 50-base long subsequence.

  Output: CGACA GAAGA
  """
  def clump(seq, subseq_len, times) do
    seq
    |> String.to_charlist
    |> Stream.chunk(subseq_len, 1)
    |> Flow.from_enumerable
    |> Flow.partition
    |> Flow.reduce(fn -> %{} end, fn w, acc ->
        Map.update(acc, w, 1, &(&1 + 1))
       end)
    |> Flow.reject(fn {_, n} -> n < times end)
    |> Flow.map(fn {seq, _} -> seq end)
    |> Flow.uniq
    |> Enum.to_list
  end
end
