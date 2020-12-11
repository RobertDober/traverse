defmodule Test.Traverse.SaveGuardTest do
  use ExUnit.Case
  # Better internal Error then a predefined one
  alias Traverse.InternalError
  alias Traverse.Open

  describe "Open.pop on empty container" do
    test "shall raise an InternalError" do
      assert_raise InternalError, fn ->
        Open.pop(Open.new([]))
      end
    end
  end
end
