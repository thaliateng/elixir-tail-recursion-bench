defmodule EnumFunctions do
  @moduledoc "Implementations using functions from the Enum module."

  def sum(list), do: Enum.sum(list)

  def factorial(0), do: 1
  def factorial(n) when is_integer(n) and n > 0, do: Enum.reduce(1..n, 1, &*/2)

  def fibonacci(n) when is_integer(n) and n >= 0 do
    Enum.reduce(1..n//1, {0, 1}, fn _, {a, b} -> {b, a + b} end) |> elem(0)
  end

  def reverse(list), do: Enum.reverse(list)

  def map(list, fun), do: Enum.map(list, fun)

  def filter(list, fun), do: Enum.filter(list, fun)

  def count_words(sentences) do
    Enum.reduce(sentences, 0, fn sentence, acc -> acc + length(String.split(sentence)) end)
  end
end
