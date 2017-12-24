defmodule Traverse.Enum.GroupedAccTest do
  use ExUnit.Case
  alias Traverse.Enum, as: E

  doctest E

  describe "Grouped Reduce" do
    test "leaves empty, empty" do 
      assert E.grouped_reduce([], fn _, _ -> raise Error, "does not happen" end) == [] 
    end

    test "even one element does not trigger the computation" do 
      assert E.grouped_reduce([true], fn _, _ -> raise Error, "does not happen" end) == [true] 
      
    end
  end

  describe "Grouped Inject" do 
    test "leaves empty with the injected" do 
      assert E.grouped_inject([], nil, fn _, _ -> raise Error, "does not happen" end) == [nil] 
    end
  end

  describe "An illegal grouping function" do
    test "raises an error" do 
      assert_raise( Traverse.Error, fn ->
        E.grouped_inject([1], 2, fn _, _ -> nil end)
      end)
    end
  end

  describe "Reversing" do
    test "reduce" do
      assert E.grouped_reduce(~w(alpha beta zeta), fn a, b ->
        if String.length(a) == String.length(b) do
          {:cont, a <> b}
        else
          {:stop, nil}
        end end, reverse: true) == ~w(alpha betazeta)
    end
  end

end
