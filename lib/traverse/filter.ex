defmodule Traverse.Filter do
  use Traverse.Types

  @doc """
  The implementation of `Traverse.filter`. 
  """
  @spec filter(any, t_simple_filter_fn) :: any
  def filter(ds, filter_fn) do
    Traverse.mapall(ds, fn ele ->
      if Traverse.Fn.complete_with_const(filter_fn, false).(ele), do: ele, else: Traverse.Ignore
    end)
  end
end
