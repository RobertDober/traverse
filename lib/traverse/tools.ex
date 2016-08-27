defmodule Traverse.Tools do

  @doc """
  DEPRECATED
  A convenience method to pass the accumulator through a substructure.
  As soon as cutting substructures is available, this will go away.
  """
  def acc_for_pre do 
    fn _fst, snd -> {snd} end
  end


  @doc """
  Utility to trace your traversals by passing your traversal function to this trace_wrapper
  """
  def make_trace_fn fun

  def make_trace_fn( fun ) when is_function(fun, 1) do
    with f <- fn e -> IO.puts ">>> #{inspect e}"
                  r = fun.(e)
                  IO.puts "<<< #{inspect r}"
                  r
    end, do: f
  end
  def make_trace_fn( fun ) when is_function(fun, 2) do
    with f <- fn e, a -> IO.puts ">>> #{inspect e}, #{inspect a}"
                  r = fun.(e, a)
                  IO.puts "<<< #{inspect r}"
                  r
    end, do: f
  end
  def make_trace_fn( fun ) when is_function(fun, 3) do
    with f <- fn e, a1, a2 -> IO.puts ">>> #{inspect e}, #{inspect a1}, #{inspect a2}"
                  r = fun.(e, a1, a2)
                  IO.puts "<<< #{inspect r}"
                  r
    end, do: f
  end
  
end
