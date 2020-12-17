defmodule Test.Traverse.VisitTest do
  use ExUnit.Case
  alias Support.{AStruct,Collector}

  describe "a complex ds" do
    test "with collector" do
      Collector.start_link
      ds = [1, %{a: [2, 3]}, {4, 5}]
      expected = [
        :open_list, 1, :open_map,
           :open_tuple, :a, :open_list, 2, 3, :close_list, :close_tuple,
        :close_map, :open_tuple,
           4, 5,
        :close_tuple, :close_list
      ]
      Traverse.visit(ds, Collector)
      assert Collector.messages == expected
    end
    test "structs too" do
      Collector.start_link
      ds = { %AStruct{a: [42]} }
      expected = [
        :open_tuple, {:open_struct, AStruct}, 
          :open_tuple, :a, :open_list, 42, :close_list, :close_tuple,
          :open_tuple, :b, nil, :close_tuple,
        {:close_struct, AStruct}, :close_tuple
      ]
      Traverse.visit(ds, Collector)
      assert Collector.messages == expected
    end
  end
end
