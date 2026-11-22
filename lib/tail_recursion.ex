defmodule TailRecursion do
  @moduledoc "Tail-recursive implementations with accumulators."

  def sum(list), do: do_sum(list, 0)
  defp do_sum([], acc), do: acc
  defp do_sum([head | tail], acc), do: do_sum(tail, acc + head)

  def factorial(n) when is_integer(n) and n >= 0, do: do_factorial(n, 1)
  defp do_factorial(0, acc), do: acc
  defp do_factorial(n, acc), do: do_factorial(n - 1, acc * n)

  def fibonacci(n) when is_integer(n) and n >= 0, do: do_fibonacci(n, 0, 1)
  defp do_fibonacci(0, a, _b), do: a
  defp do_fibonacci(n, a, b), do: do_fibonacci(n - 1, b, a + b)

  def reverse(list), do: do_reverse(list, [])
  defp do_reverse([], acc), do: acc
  defp do_reverse([head | tail], acc), do: do_reverse(tail, [head | acc])

  def map(list, fun), do: do_map(list, fun, [])
  defp do_map([], _fun, acc), do: do_reverse(acc, [])
  defp do_map([head | tail], fun, acc), do: do_map(tail, fun, [fun.(head) | acc])

  def filter(list, fun), do: do_filter(list, fun, [])
  defp do_filter([], _fun, acc), do: do_reverse(acc, [])

  defp do_filter([head | tail], fun, acc) do
    if fun.(head) do
      do_filter(tail, fun, [head | acc])
    else
      do_filter(tail, fun, acc)
    end
  end

  def count_words(sentences), do: do_count_words(sentences, 0)
  defp do_count_words([], acc), do: acc

  defp do_count_words([sentence | sentences], acc) do
    do_count_words(sentences, acc + length(String.split(sentence)))
  end
end
