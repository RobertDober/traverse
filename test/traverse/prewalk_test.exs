defmodule Traverse.WalkerTest do
  use ExUnit.Case

  alias Traverse.Walker
  import Support.Functions

  doctest Traverse.Walker

  describe "prewalk" do
    test "a scalar" do
      result = Walker.walk(1, 1, adder())
      assert result == 2
    end
    test "a list" do
      result = Walker.walk([1, 2], 1, adder())
      assert result == 4
    end
    @tag :wip
    test "collect list sizes" do
      result = Walker.walk([[1, 2], [:a]], 0, collect_list_sizes())
      assert result == 3
    end
    test "cutting (edge?)" do
      result = Traverse.Walker.walk( {1, [2, %{a: 3}, 4], 5}, 0, &add_with_cut/2 )
      assert result == 12
    end
  end

  defp collector(ele, acc), do: [ele | acc]

  defp add_with_cut(ele, acc)
  defp add_with_cut(n, acc) when is_number(n), do: acc + n
  defp add_with_cut(mp, acc) when is_map(mp), do: %Traverse.Cut{acc: acc}
  defp add_with_cut(_, acc), do: acc
end
