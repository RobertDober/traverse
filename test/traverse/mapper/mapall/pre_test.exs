defmodule Traverse.Mapper.Mapall.PreTest do
  use ExUnit.Case

  import Traverse

  describe "Traverse.mapall(post: false) empty cases" do
    test "list with complete fn" do
      assert mapall([], const(1)) == 1 
    end

    test "list with partial fn" do
      assert mapall([], fn 1 -> 2 end) == []
    end

    test "list with error fn" do
      assert mapall([], inc()) == []
    end

    test "tuple with complete fn" do
      assert mapall({}, const(2)) == 2 
    end

    test "tuple with partial fn" do
      assert mapall({}, fn 2 -> 3 end) == {}
    end

    test "tuple with error fn" do
      assert mapall({}, inc()) == {}
    end

    test "map with complete fn" do
      assert mapall(%{}, const(2)) == 2
    end

    test "map with partial fn" do
      assert mapall(%{}, fn 2 -> 3 end) == %{}
    end

    test "map with error fn" do
      assert mapall(%{}, inc()) == %{}
    end
  end


  describe "Traverse.mapall(post: false) flat" do
    test "list with numbers" do
      assert mapall([1, 2], inc()) == [2, 3]
    end

    test "string with error function" do
      assert_raise(FunctionClauseError, fn ->
        mapall({"hello"}, inc())
      end)
    end
  end

  describe "deep" do
    test "safe incrementing" do
      assert mapall([1, {:a, 2}, %{a: [3, {}, 4]}], &safe_inc/1) == [2, {:a, 3}, %{a: [4, {}, 5]}]
    end

    test "not touching keys" do
      assert mapall([1, {:a, 2}, %{0 => [3, {}, 4]}], &safe_inc/1) == [
               2,
               {:a, 3},
               %{0 => [4, {}, 5]}
             ]
    end

    test "transform tuples and remove empty lists" do
      assert mapall({[], :a, {[], [2]}}, &trans/1) == [ :a, [[2]] ]
    end

    test "remove empty lists from maps" do
      assert mapall(%{a: [], b: {"hello"}}, &trans/1) == %{b: ["hello"]}
    end
  end


  defp inc, do: fn x when is_number(x) -> x + 1 end
  defp safe_inc(x) when is_number(x), do: x + 1
  defp safe_inc(x), do: x

  defp const(c), do: fn _ -> c end

  defp trans(tuple) when is_tuple(tuple), do: Tuple.to_list(tuple)
  defp trans([]), do: Traverse.Ignore
  defp trans(x), do: x
end
