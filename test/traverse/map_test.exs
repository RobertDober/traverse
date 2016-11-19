defmodule Traverse.MapTest do
  use ExUnit.Case
  import Traverse, only: [map: 2]

  doctest Traverse.Mapper
  
  describe "map flat data structures" do
    test "flat list" do 
      flat = [:a, "hello", 42]
      expected = [:a, "hello", 43]

      assert map(flat, &increment/1) == expected
    end
    test "flat tuple" do 
      flat = { :a, "hello", 42, 0 }
      expected = { :a, "hello", 43, 1 }
      assert map(flat, &increment/1) == expected
    end
    test "empty list" do 
      assert map([], &error/1) == []
    end
    test "empty tuple" do 
      assert map({}, &error/1) == {}
    end
    test "empty map" do 
      assert map(%{}, &error/1) == %{}
    end
  end

  describe "map deep data structures" do

    test "a list of ..." do 
      ds       = [ :a, {:b, 1, [c: 2], %{:a => {0}, 2 => [1, :c]}}, 41 ]
      expected = [ :a, {:b, 2, [c: 3], %{:a => {1}, 2 => [2, :c]}}, 42 ]
      # N.B. Keys are not transformed
      assert map(ds, &increment/1) == expected
      
    end

  end

  defp increment(x) when is_number(x), do: x + 1
  defp increment(x), do: x

  defp error(_), do: raise "Oh no I was not supposed to be raised"
end
