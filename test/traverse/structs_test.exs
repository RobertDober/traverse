defmodule Traverse.StructsTest do
  use ExUnit.Case

  import Traverse
  alias Support.Var

  @vars [%Var{name: "alpha", value: 30}, %Var{name: "beta", value: 60}]
  @dbld [%Var{name: "alpha", value: 60}, %Var{name: "beta", value: 120}]
  describe "traversal" do
    test "they can be traversed" do
      double_angles = fn
        %{value: value} = m, acc -> [%{m | value: 2 * value} | acc]
        _, acc -> acc
      end

      assert walk(@vars, [], double_angles) == Enum.reverse(@dbld)
    end

    test "traversal with postwalk" do
      double_angles = fn
        %{value: value} = m, acc -> [%{m | value: 2 * value} | acc]
        _, acc -> acc
      end

      assert walk(@vars, [], double_angles, postwalk: true) == Enum.reverse(@dbld)
    end
  end

  describe "mapping" do
    test "they can be mapped" do
      double_angles = fn
        m when is_number(m) -> 2 * m
        x -> x
      end

      assert map(@vars, double_angles) == @dbld
    end

    test "and mapped!" do
      double_angles = fn
        m when is_number(m) -> 2 * m
        x -> x
      end

      assert map!(@vars, double_angles) == @dbld
    end
  end

  describe "filtering" do 
    test "they can be filtered" do
      thirty = fn
        %{value: 30} -> true
        %{value: 60} -> false
        _            -> true
      end
      assert filter(@vars, thirty) == [hd(@vars)]
    end

    test "also by using mapall post: true" do
      thirty = fn
        %{value: 30}=x -> struct(Var, x) # We need to hint the postwalker with what we want here 
        %{value: 60}   -> Traverse.Ignore
        x              -> x
      end
      assert mapall(@vars, thirty, post: true) == [hd(@vars)]
    end
    
    
  end
end
