defmodule Traverse.Mapper.Mapall.IncompleteMapperTest do
  use ExUnit.Case

  import Traverse, only: [mapall: 3]

  @int_nodes [{0, 1}, %{b: 2, c: [3, 4]}]
  @preincremented [{1, 2}, %{b: 3, c: [4, 5]}]
  @postincremented [[ 1, 2 ], %{b: 3, c: [4, 5]}]
  @mixed_nodes [{:a, 1, :b}, %{b: 2, c: ["hello", 3, 4]}]

  describe "save inc is completed for inner nodes" do
    test "post" do
      assert post(@int_nodes, &save_inc/1) == @postincremented
    end
    test "pre" do
      assert pre(@int_nodes, &save_inc/1) == @preincremented
    end
  end

  describe "unsave inc is not completed for inner nodes" do
    test "post" do
      assert_raise(ArithmeticError, fn -> post(@int_nodes, &unsave_inc/1) end)
    end
    test "pre" do
      assert_raise(ArithmeticError, fn -> pre(@int_nodes, &unsave_inc/1) end)
    end
  end

  describe "save inc is not completed for leave nodes" do
    test "post" do
      assert_raise(FunctionClauseError, fn -> post(@mixed_nodes, &save_inc/1) end)
    end
    test "pre" do
      assert_raise(FunctionClauseError, fn -> pre(@mixed_nodes, &save_inc/1) end)
    end
  end

  describe "unsave inc is not completed for leave nodes" do
    test "post" do
      assert_raise(ArithmeticError, fn -> post(@mixed_nodes, &unsave_inc/1) end)
    end
    test "pre" do
      assert_raise(ArithmeticError, fn -> pre(@mixed_nodes, &unsave_inc/1) end)
    end
  end

  defp post(ds, mapper), do: mapall(ds, mapper, post: true)
  defp pre(ds, mapper), do: mapall(ds, mapper, post: false)

  defp save_inc(n) when is_number(n), do: n+1
  defp unsave_inc(n), do: n+1
  
end
