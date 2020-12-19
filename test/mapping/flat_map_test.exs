defmodule Test.Traverse.Mapping.FlatMapTest do
  use ExUnit.Case
  import Traverse, only: [flat_map: 2, flat_map: 3]

  describe "flat_map" do
    setup :data

    test "increase by one", %{data: data} do
      assert flat_map(data, &(&1+1), ignore_keys: true) == [1, 2, 3, 4] 
    end

    test "take care of map keys", %{data: data} do
      mapper =
        fn n when is_number(n) -> n + 1
           _                   -> 0 end
      assert flat_map(data, mapper) == [1,2,0,3,4]
    end
  end

  def data(_context) do
    [data: [{0, {1, %{b: 2}}, 3}]]
  end
end
