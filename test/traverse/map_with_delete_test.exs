defmodule Traverse.MapWithDeleteTest do
  use ExUnit.Case
  import Traverse, only: [map: 2]
  
  defmodule SquarePositives do 
    
  end

  describe "map with delete" do
    test "no negs" do 
      original = [a: 1, b: -2, rest: {:a, 10, :b, -20}]
      assert map(original, fn x when is_number(x) -> if x < 0, do: Traverse.Ignore, else: x * x
                              other               -> other end) == [{:a, 1}, {:b}, {:rest, {:a, 100, :b}}]
    end
  end
end
