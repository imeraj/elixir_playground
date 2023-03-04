defmodule GeneratorTest do
  use ExUnit.Case
  use PropCheck

  property "find all keys in a map even when dupes are used", [:verbose] do
    forall kv <- list({key(), val()}) do
      m = Map.new(kv)
      for {k, _v} <- kv, do: Map.fetch!(m, k)

      uniques =
        kv
        |> List.keysort(0)
        |> Enum.dedup_by(fn {x, _} -> x end)

      collect(true, {:dupes, to_range(5, length(kv) - length(uniques))})
    end
  end

  property "collect 1", [:verbose] do
    forall bin <- binary() do
      collect(is_binary(bin), byte_size(bin))
    end
  end

  property "collect 2", [:verbose] do
    forall bin <- binary() do
      collect(is_binary(bin), to_range(10, byte_size(bin)))
    end
  end

  property "aggregate 1", [:verbose] do
    suits = [:club, :diamond, :heart, :spade]

    forall hand <- vector(5, {oneof(suits), choose(1, 13)}) do
      # always pass
      aggregate(true, hand)
    end
  end

  property "fake escaping test showcasing aggregation", [:verbose] do
    forall str <- utf8() do
      aggregate(escape(str), classes(str))
    end
  end

  defp escape(_str), do: true

  def classes(str) do
    l = letters(str)
    n = numbers(str)
    p = punctuation(str)
    o = String.length(str) - (l + n + p)

    [
      {:letters, to_range(5, l)},
      {:numbers, to_range(5, n)},
      {:punctuation, to_range(5, p)},
      {:others, to_range(5, o)}
    ]
  end

  defp letters(str) do
    is_letter = fn c -> (c >= ?a && c <= ?z) || (c >= ?A && c <= ?Z) end
    length(for <<c::utf8 <- str>>, is_letter.(c), do: 1)
  end

  def numbers(str) do
    is_num = fn c -> c >= ?0 && c <= ?9 end
    length(for <<c::utf8 <- str>>, is_num.(c), do: 1)
  end

  def punctuation(str) do
    is_punctuation = fn c -> c in '.,;:\'"-' end
    length(for <<c::utf8 <- str>>, is_punctuation.(c), do: 1)
  end

  defp to_range(m, n) do
    base = div(n, m)
    {base * m, (base + 1) * m}
  end

  # Generators
  defp key, do: oneof([range(1, 10), integer()])
  defp val, do: term()
end
