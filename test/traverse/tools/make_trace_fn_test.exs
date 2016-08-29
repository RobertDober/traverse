defmodule Traverse.Tools.MakeTraceFnTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  import Traverse.Tools

  defp fn1, do: fn n -> 2 * n end
  defp fn2, do: fn n, m -> 10 * n + m end
  defp fn3, do: fn n, m, k -> 100 * n + 10 * m + k end

  test "1 arg" do 
    assert capture_io(:stderr, fn -> make_trace_fn(fn1).(21) 
    end) == ">>> 21\n<<< 42\n"
    capture_io( :stderr, fn ->
      assert capture_io( fn -> make_trace_fn(fn1).(21) 
      end) == ""
    end)
  end

  test "2 args" do 
    assert capture_io(:stderr, fn -> make_trace_fn(fn2).(4, 2) 
    end) == ">>> 4, 2\n<<< 42\n"
    capture_io( :stderr, fn ->
      assert capture_io( fn -> make_trace_fn(fn2).(4, 2) 
      end) == ""
    end)
  end

  test "3 args" do 
    assert capture_io(:stderr, fn -> make_trace_fn(fn3).(17, 6, 4) 
    end) == ">>> 17, 6, 4\n<<< 1764\n"
    capture_io( :stderr, fn ->
      assert capture_io( fn -> make_trace_fn(fn3).(1, 2, 3) 
      end) == ""
    end)
  end
end
