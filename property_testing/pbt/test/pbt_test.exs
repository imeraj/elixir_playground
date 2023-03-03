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
      biggest(x) == List.last(Enum.sort(x))
    end
  end

  property "list sequence increases" do
    forall {start, count} <- {integer(), non_neg_integer()} do
      list = Enum.to_list(start..(start + count))
      count + 1 == length(list) and increments(list)
    end
  end

  # helpers
  defp boolean(_), do: true

  defp biggest([head | tail]) do
    biggest(tail, head)
  end

  defp biggest([], max), do: max

  defp biggest([head | tail], max) when head >= max, do: biggest(tail, head)

  defp biggest([head | tail], max) when head < max, do: biggest(tail, max)

  defp increments([head | tail]), do: increments(head, tail)

  defp increments(_, []), do: true

  defp increments(n, [head | tail]) when head == n + 1, do: increments(head, tail)

  defp increments(_, _), do: false

  # generators
  defp my_type(), do: term()
end
