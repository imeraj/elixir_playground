ex2 = fn
  0, 0, _ -> "FizBuzz"
  0, _, _ -> "Fizz"
  _, 0, _ -> "Buzz"
  _, _, c -> c
end

IO.puts(ex2.(0, 0, 1))
IO.puts(ex2.(0, 1, 1))
IO.puts(ex2.(1, 0, 0))
IO.puts(ex2.(1, 2, 3))

fizz_word = fn a -> ex2.(rem(a, 3), rem(a, 5), a) end

IO.puts(fizz_word.(10))
IO.puts(fizz_word.(11))
IO.puts(fizz_word.(12))
IO.puts(fizz_word.(13))
IO.puts(fizz_word.(14))
IO.puts(fizz_word.(15))
IO.puts(fizz_word.(16))

prefix = fn pre -> fn suffix -> pre <> " " <> suffix end end

IO.puts(prefix.("Mr.").("Meraj"))

defmodule Factorial do
  def of(0), do: 1
  def of(n), do: n * of(n - 1)
end

IO.puts(Factorial.of(4))

defmodule Sum do
  def sum(1), do: 1
  def sum(n), do: n + sum(n - 1)
end

IO.puts(Sum.sum(5))

defmodule GCD do
  def gcd(x, 0) when x > 0, do: x
  def gcd(x, y) when x > 0 and y > 0, do: gcd(y, rem(x, y))
  def gcd(_, _), do: "wrong input"
end

IO.puts(GCD.gcd(4, 5))
IO.puts(GCD.gcd(2, 4))
IO.puts(GCD.gcd(-2, 4))

defmodule Chop do
  def mid(a, b), do: div(a + b, 2)

  defguardp is_greater(n, a, b) when n > div(a + b, 2)
  defguardp is_lesser(n, a, b) when n < div(a + b, 2)
  defguardp is_equal(n, a, b) when n == div(a + b, 2)

  def guess(n, a..b) when is_greater(n, a, b) do
    guess(n, (mid(a, b) + 1)..b)
  end

  def guess(n, a..b) when is_lesser(n, a, b) do
    guess(n, a..(mid(a, b) - 1))
  end

  def guess(n, a..b) when is_equal(n, a, b) do
    "It is #{n}"
  end
end

IO.puts(Chop.guess(50, 1..100))
IO.puts(Chop.guess(273, 1..500))

defmodule MyList do
	def len([]), do: 0
	def len([_head | tail]), do: 1 + len(tail)

  def span(from, to) when from > to, do: []
  def span(from, to), do: [from | span(from + 1, to)]
end

IO.puts(MyList.len([]))
IO.puts(MyList.len([1, 2 ,3]))
IO.puts(MyList.len([1, [2 ,3]]))

IO.inspect(MyList.span(5, 10), label: "valid")
IO.inspect(MyList.span(10, 5), label: "invalid")
IO.inspect(MyList.span(0, 5),  label: "valid")

defmodule MyMap do
  def map([], _func), do: []
  def map([head | tail], func), do: [func.(head) | map(tail, func)]
end

IO.inspect(MyMap.map([1, 2, 3, 4], &(&1 * 2)), label: "multiply by 2", limit: 2)
IO.inspect(MyMap.map([1, 2, 3, 4], &(&1 * &1)), label: "double each elem")

defmodule MySum do
  def sum([]), do: 0
  def sum([head | tail]), do: head + sum(tail)
end

IO.puts(MySum.sum([1, 2, 3, 4, 5]))
IO.puts(MySum.sum([-100]))

people = [
	%{ name: "Grumpy", height: 1.24 },
	%{ name: "Dave", height: 1.88 },
	%{ name: "Dopey", height: 1.32 },
	%{ name: "Shaquille", height: 2.16 },
	%{ name: "Sneezy", height: 1.28 }
]

for person = %{ height: height } <- people, height > 1.5,
    do: IO.inspect person
