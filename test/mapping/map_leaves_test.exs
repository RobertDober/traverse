defmodule Test.Traverse.Mapping.MapLeavesTest do
  use ExUnit.Case
  import Traverse, only: [map_leaves: 2, map_leaves: 3]

  describe "map_leaves" do
    setup [:data, :simple]

    test "only tuples and lists", %{simple: simple} do
      assert map_leaves(simple, &(&1+1)) == [2, {3, 4, [5]}, [6]]
    end

    test "increase by one", %{data: data} do
      assert map_leaves(data, &(&1+1), ignore_keys: true) == [{1, {2, %{b: 3}}, 4}]
    end

    test "take care of map keys", %{data: data} do
      mapper =
        fn n when is_number(n) -> n + 1
           _                   -> :c end
      assert map_leaves(data, mapper) == [{1, {2, %{c: 3}}, 4}]
    end
  end

  def data(_context) do
    [data: [{0, {1, %{b: 2}}, 3}]]
  end
  def simple(_context) do
    [simple: [1, {2, 3, [4]}, [5]]]
  end
end

