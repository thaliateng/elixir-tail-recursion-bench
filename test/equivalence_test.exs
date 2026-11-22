defmodule EquivalenceTest do
  use ExUnit.Case, async: true

  @moduledoc "Checks that the three strategies return the same results."

  @strategies [BodyRecursion, TailRecursion, EnumFunctions]
  @sizes [0, 1, 2, 10, 1_000]

  defp all_equal(fun) do
    [first | rest] = Enum.map(@strategies, fun)
    Enum.each(rest, fn result -> assert result == first end)
    first
  end

  describe "known values" do
    test "sum/1 of an integer list" do
      list = Enum.to_list(1..10_000)
      expected = 50_005_000

      assert BodyRecursion.sum(list) == expected
      assert TailRecursion.sum(list) == expected
      assert EnumFunctions.sum(list) == expected
    end

    test "reverse/1 of a list" do
      list = [1, 2, 3, 4, 5]
      expected = [5, 4, 3, 2, 1]

      assert BodyRecursion.reverse(list) == expected
      assert TailRecursion.reverse(list) == expected
      assert EnumFunctions.reverse(list) == expected
    end

    test "factorial/1 with known values" do
      assert all_equal(& &1.factorial(0)) == 1
      assert all_equal(& &1.factorial(1)) == 1
      assert all_equal(& &1.factorial(5)) == 120
      assert all_equal(& &1.factorial(20)) == 2_432_902_008_176_640_000
    end

    test "factorial/1 with big integers" do
      all_equal(& &1.factorial(1_000))
    end

    test "fibonacci/1 with known values" do
      assert all_equal(& &1.fibonacci(0)) == 0
      assert all_equal(& &1.fibonacci(1)) == 1
      assert all_equal(& &1.fibonacci(10)) == 55
      assert all_equal(& &1.fibonacci(20)) == 6765
      assert all_equal(& &1.fibonacci(90)) == 2_880_067_194_370_816_120
    end

    test "fibonacci/1 with big integers" do
      all_equal(& &1.fibonacci(1_000))
    end

    test "map/2 with the same function" do
      assert all_equal(& &1.map([1, 2, 3], fn x -> x * 2 end)) == [2, 4, 6]
    end

    test "filter/2 with the same predicate" do
      assert all_equal(& &1.filter([1, 2, 3, 4, 5, 6], fn x -> rem(x, 2) == 0 end)) ==
               [2, 4, 6]
    end

    test "count_words/1 with known sentences" do
      sentences = ["recursao de cauda", "elixir", "  espacos   extras  ", ""]
      assert all_equal(& &1.count_words(sentences)) == 6
    end
  end

  describe "benchmark inputs" do
    for n <- @sizes do
      @n n

      test "list functions with n = #{n}" do
        list = Inputs.integer_list(@n)

        assert all_equal(& &1.sum(list)) == Enum.sum(list)
        assert all_equal(& &1.reverse(list)) == Enum.reverse(list)

        assert all_equal(& &1.map(list, fn x -> Inputs.double(x) end)) ==
                 Enum.map(list, &Inputs.double/1)

        assert all_equal(& &1.filter(list, fn x -> Inputs.even?(x) end)) ==
                 Enum.filter(list, &Inputs.even?/1)
      end

      test "count_words/1 with n = #{n} sentences" do
        sentences = Inputs.sentences(@n)
        assert all_equal(& &1.count_words(sentences)) == @n * 10
      end
    end
  end

  describe "Inputs" do
    test "sentences/2 is deterministic" do
      assert Inputs.sentences(50) == Inputs.sentences(50)
    end
  end
end
