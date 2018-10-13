defmodule Traverse.Implementations.EnumTest do
  use ExUnit.Case
  
  alias Support.EnumStruct

  test "struct implements Enumerable" do
    mapped = %EnumStruct{}
      |> Enum.flat_map( fn {k, v} -> [v, k] end)
      
    assert mapped == ["The first", :alpha, "The last", :omega]
  end
end
