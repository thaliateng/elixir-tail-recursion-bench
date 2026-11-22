defmodule BodyRecursion do
  @moduledoc "Body-recursive implementations."

  def sum([]), do: 0
  def sum([head | tail]), do: head + sum(tail)

  def factorial(0), do: 1
  def factorial(n) when is_integer(n) and n > 0, do: n * factorial(n - 1)

  def fibonacci(n) when is_integer(n) and n >= 0, do: n |> fib_pair() |> elem(0)

  defp fib_pair(0), do: {0, 1}

  defp fib_pair(n) do
    {a, b} = fib_pair(n - 1)
    {b, a + b}
  end

  # Quadratic on purpose: the naive body-recursive version discussed in the paper.
  def reverse([]), do: []
  def reverse([head | tail]), do: reverse(tail) ++ [head]

  def map([], _fun), do: []
  def map([head | tail], fun), do: [fun.(head) | map(tail, fun)]

  def filter([], _fun), do: []

  def filter([head | tail], fun) do
    if fun.(head), do: [head | filter(tail, fun)], else: filter(tail, fun)
  end

  def count_words([]), do: 0

  def count_words([sentence | sentences]) do
    length(String.split(sentence)) + count_words(sentences)
  end
end
