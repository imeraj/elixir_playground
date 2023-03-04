defmodule PbtTest do
  use ExUnit.Case
  use PropCheck

  # properties
  property "always works" do
    forall type <- my_type() do
      boolean(type)
    end
  end

  property "find biggest element" do
    forall x <- non_empty(list(integer())) do
      Pbt.biggest(x) == model_biggest(x)
    end
  end

  property " list sequence increases" do
    forall {start, count} <- {integer(), non_neg_integer()} do
      list = Enum.to_list(start..(start + count))
      count + 1 == length(list) and Pbt.increments(list)
    end
  end

  property "picks the last number" do
    forall {list, known_last} <- {list(number()), number()} do
      known_list = list ++ [known_last]
      known_last == List.last(known_list)
    end
  end

  property "a sorted list has ordered pairs" do
    forall list <- list(term()) do
      is_ordered(Enum.sort(list))
    end
  end

  property "a sorted list keeps its size" do
    forall l <- list(number()) do
      length(l) == length(Enum.sort(l))
    end
  end

  property "no element added" do
    forall l <- list(number()) do
      sorted = Enum.sort(l)
      Enum.all?(sorted, &(&1 in l))
    end
  end

  property "no element deleted" do
    forall l <- list(number()) do
      sorted = Enum.sort(l)
      Enum.all?(l, &(&1 in sorted))
    end
  end

  property "symmetric encoding/decoding" do
    forall data <- list({atom(), any()}) do
      encoded = encode(data)
      is_binary(encoded) and data == decode(encoded)
    end
  end

  # models
  defp model_biggest(list), do: List.last(Enum.sort(list))

  # helpers
  defp boolean(_), do: true

  defp is_ordered([a, b | t]) do
    a <= b and is_ordered([b | t])
  end

  defp is_ordered(_), do: true

  defp encode(t), do: :erlang.term_to_binary(t)
  defp decode(t), do: :erlang.binary_to_term(t)

  # generators
  defp my_type, do: term()
end
