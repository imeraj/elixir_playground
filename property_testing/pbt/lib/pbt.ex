defmodule Pbt do
  def biggest([head | tail]) do
    biggest(tail, head)
  end

  def increments([head | tail]), do: increments(head, tail)

  defp biggest([], max), do: max

  defp biggest([head | tail], max) when head >= max, do: biggest(tail, head)

  defp biggest([head | tail], max) when head < max, do: biggest(tail, max)

  defp increments(_, []), do: true

  defp increments(n, [head | tail]) when head == n + 1, do: increments(head, tail)

  defp increments(_, _), do: false
end
