defmodule TraverseTest do
  use ExUnit.Case

  import Traverse

  doctest Traverse

  describe "walk" do
    @ds_cut %{a: %{ignore: [1, 3, 4]}, b: 10, c: %{e: 20, d: [f: 30, ignore: 1000]}}
    test "cutting" do
      collector = fn
        ele, acc when is_number(ele) -> acc + ele
        {:ignore, _}, acc -> %Traverse.Cut{acc: acc}
        _, acc -> acc
      end

      assert walk(@ds_cut, 0, collector) == 60
    end
  end
end
