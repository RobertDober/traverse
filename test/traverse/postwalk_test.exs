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

  defp add_with_cut(ele, acc)
  defp add_with_cut(n, acc) when is_number(n), do: acc + n
  defp add_with_cut(mp, acc) when is_map(mp), do: %Traverse.Cut{acc: acc}
  defp add_with_cut(_, acc), do: acc
end
