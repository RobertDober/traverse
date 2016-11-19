defmodule Traverse.IgnoreTest do
  use ExUnit.Case
  
  import Traverse.Ignore
  doctest Traverse.Ignore

  describe "me?" do
    test "me" do 
      assert me?(Traverse.Ignore) 
    end
    test "not me" do
      assert !me?(nil)
      assert !me?(42)
      assert !me?(%{})
    end
  end
end
