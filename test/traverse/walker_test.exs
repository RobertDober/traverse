defmodule Traverse.WalkerTest do
  use ExUnit.Case

  import Traverse.Walker

  doctest Traverse.Walker

  describe "postwalk" do
    test "empty" do
      assert postwalk([], [], &collector/2) == [[]]
    end

    @desc_bef_call [:a, [:b, 1]]
    test "descending before calling function" do
      assert postwalk(@desc_bef_call, [], &collector/2) == [[:a, [:b, 1]], [:b, 1], 1, :b, :a]
    end
  end

  defp collector(ele, acc), do: [ele | acc]
end
