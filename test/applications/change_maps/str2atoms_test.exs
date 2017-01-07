defmodule Applications.ChangeMaps.Str2atomsTest do
  use ExUnit.Case
  
  alias Traverse.Fn
  import Traverse

  describe "string keys to atom keys" do

    test "base case" do
      assert atomize(%{"b" => 2, 3 => :three, a: 1}) == %{3 => :three, a: 1, b: 2}
    end

    @source %{"a" => 1, "c" => [%{"e" => 3}, "hello"], b: "two"}
    @target %{a: 1, b: "two", c: [%{e: 3}, "hello"]}
    test "descending case" do
      assert mapall([@source], Fn.complete_with_identity(&atomize/1)) == [@target]
    end
  end

  defp atomize(map) when is_map(map) do
    # If we do not descend Traverse is not the tool to use, Enum is just great :).
    convert = Fn.complete_with_identity(&String.to_atom/1)
    Enum.reduce(map, %{}, fn {k, v}, a -> Map.put(a, convert.(k), v) end)
  end
end
