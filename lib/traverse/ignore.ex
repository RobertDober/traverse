defmodule Traverse.Ignore do
  @moduledoc """
  When a transformer function returns this value the transformation of the
  containing data structure will not contain it, in case the containing data structure is
  a map the key is omitted in the transformation.

  iex(0)> Traverse.map([1, 2, %{a: 1}, {1, 2}], fn _ -> Traverse.Ignore end)
  [%{a: nil}, {}]
  """
  @doc """
  Lackmus to decide if an argument is to be ignored, or, in other words, is me.
  """
  def me?(__MODULE__), do: true
  def me?(_), do: false
end


