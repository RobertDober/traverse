defmodule Traverse.Mapper.Mapall.PostTest do
  use ExUnit.Case

  describe "Traverse.mapall(post: false) empty cases" do
    test "list with complete fn" do
      assert mapall([], const(1)) == 1
    end

    test "list with partial fn" do
      assert mapall([], fn 1 -> 2 end) == []
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
      assert mapall(%{}, const(2)) == %{}
    end

    test "map with partial fn" do
      assert mapall(%{}, fn 2 -> 3 end) == %{}
    end

    test "map with error fn" do
      assert mapall(%{}, inc()) == %{}
    end
  end

  describe "Traverse.mapall(post: false) scalars" do
    test "number with complete fn" do
      assert mapall(42, const(1)) == 1
    end

    test "number with partial fn" do
      assert_raise(FunctionClauseError, fn ->  mapall("hello", fn 1 -> 3 end) == "hello" end)
    end

    test "string with partial fn" do
      assert_raise(FunctionClauseError, fn ->  mapall("hello", fn 1 -> 4 end) == "hello" end)
    end
  end

  describe "Traverse.mapall(post: false) flat" do
    test "list with numbers" do
      assert mapall([1, 2], inc()) == [2, 3]
    end

    test "mixed list" do
      assert mapall([1, :a, 2], safe_inc()) == [2, :a, 3]
    end

    test "string with error function" do
      assert_raise(FunctionClauseError, fn ->
        mapall({"hello"}, inc())
      end)
    end
  end

  describe "deep" do
    test "safe incrementing" do
      assert mapall([1, {:a, 2}, %{a: [3, {}, 4]}], safe_inc()) == [2, {:a, 3}, %{a: [4, {}, 5]}]
    end

    test "not touching keys" do
      assert mapall([1, {:a, 2}, %{0 => [3, {}, 4]}], safe_inc()) == [
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

  defp mapall(ds, f), do: Traverse.mapall(ds, f, post: true)

  defp inc, do: fn x when is_number(x) -> x + 1 end
  defp safe_inc, do: fn x when is_number(x) -> x + 1
                        x                   -> x end
  defp const(c), do: fn _ -> c end

  defp trans(tuple) when is_tuple(tuple), do: Tuple.to_list(tuple)
  defp trans([]), do: Traverse.Ignore
  defp trans(x), do: x
end
