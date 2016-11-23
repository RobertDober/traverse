defmodule Traverse.Mapper.Mapall.PreTest do
  use ExUnit.Case

  describe "Traverse.mapall(post: false) empty cases" do
    test "list with complete fn" do
      assert mapall([], const(1)) == []
    end
    test "list with partial fn" do
      assert mapall([], fn 1 -> 2 end) == []
    end
    test "list with error fn" do
      assert mapall([], inc) == []
    end
    test "tuple with complete fn" do
      assert mapall({}, const(2)) == {}
    end
    test "tuple with partial fn" do
      assert mapall({}, fn 2 -> 3 end) == {}
    end
    test "tuple with error fn" do
      assert mapall({}, inc) == {} 
    end
    test "map with complete fn" do
      assert mapall(%{}, const(2)) == %{}
    end
    test "map with partial fn" do
      assert mapall(%{}, fn 2 -> 3 end) == %{}
    end
    test "map with error fn" do
      assert mapall(%{}, inc) == %{} 
    end
  end

  describe "Traverse.mapall(post: false) scalars" do
    test "number with complete fn" do
      assert mapall(42, const(1)) == 1 
    end
    test "number with partial fn" do
      assert mapall(42, fn 1 -> 3 end) == 42 
    end
    test "string with partial fn" do
      assert mapall("hello", fn 1 -> 4 end) == "hello"
    end
    test "string with error function" do
      assert_raise( ArithmeticError, fn ->
        mapall("hello", inc)
      end)
    end
  end

  describe "Traverse.mapall(post: false) flat" do
    
  end
  defp mapall(ds, f), do: Traverse.mapall(ds, f)
  defp identity, do: fn x -> x end
  defp inc, do: fn x -> x + 1 end
  defp const(c), do: fn _ -> c end
end
