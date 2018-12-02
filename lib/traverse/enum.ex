defmodule Traverse.Enum do
  use Traverse.Types

  @doc """
  A prefilter to `Enum.reduce`, removing `:__struct__` from maps
  """

  @spec reduce(any, any, t_simple_walker_fn) :: any
  def reduce(ds, acc, fun)
  def reduce(%{__struct__: _type}=struct, acc, fun) do
    struct
    |> Map.delete(:__struct__)
    |> Enum.reduce(acc, fun)
  end
  def reduce(ds, acc, fun), do: Enum.reduce(ds, acc, fun)

end
