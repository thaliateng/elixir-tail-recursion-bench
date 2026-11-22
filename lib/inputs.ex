defmodule Inputs do
  @moduledoc "Deterministic inputs shared by the tests and the benchmarks."

  @vocabulary ~w(
    elixir erlang beam processo lista funcao recursao cauda pilha memoria
    tempo dado valor chave mapa filtro soma modulo teste codigo
  )

  @doc "List of integers from 1 to `n` (empty when `n` is 0)."
  def integer_list(0), do: []
  def integer_list(n) when is_integer(n) and n > 0, do: Enum.to_list(1..n)

  @doc "`n` sentences of `words_per_sentence` words drawn from a fixed vocabulary."
  def sentences(n, words_per_sentence \\ 10) when is_integer(n) and n >= 0 do
    # Fixed seed so every run and every strategy sees the same sentences.
    :rand.seed(:exsss, {2026, 11, 20})
    size = length(@vocabulary)
    vocabulary = List.to_tuple(@vocabulary)

    for _ <- 1..n//1 do
      1..words_per_sentence
      |> Enum.map(fn _ -> elem(vocabulary, :rand.uniform(size) - 1) end)
      |> Enum.join(" ")
    end
  end

  @doc "Function passed to `map/2`."
  def double(x), do: x * 2

  @doc "Predicate passed to `filter/2`."
  def even?(x), do: rem(x, 2) == 0
end
