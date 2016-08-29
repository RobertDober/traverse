defmodule Traverse.Tools do

  use Traverse.Types


  @doc """
  Utility to trace your traversals by passing your traversal function to this trace_wrapper.

  Instead of passing `f` you can pass `make_trace_fn(f)` as long as f is of the correct type.

  This wrapper will trace the actual arguments and the return value to stderr.
  """

  @spec make_trace_fn( t_traceable_fn ) :: t_traceable_fn
  def make_trace_fn fun

  def make_trace_fn( fun ) when is_function(fun, 1) do
    with f <- fn e -> IO.puts :stderr, ">>> #{inspect e}"
                  r = fun.(e)
                  IO.puts :stderr, "<<< #{inspect r}"
                  r
    end, do: f
  end
  def make_trace_fn( fun ) when is_function(fun, 2) do
    with f <- fn e, a -> IO.puts :stderr, ">>> #{inspect e}, #{inspect a}"
                  r = fun.(e, a)
                  IO.puts :stderr, "<<< #{inspect r}"
                  r
    end, do: f
  end
  def make_trace_fn( fun ) when is_function(fun, 3) do
    with f <- fn e, a1, a2 -> IO.puts :stderr, ">>> #{inspect e}, #{inspect a1}, #{inspect a2}"
                  r = fun.(e, a1, a2)
                  IO.puts :stderr, "<<< #{inspect r}"
                  r
    end, do: f
  end
end
