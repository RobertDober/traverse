defmodule Traverse.Cut do
  @moduledoc """
  A wrapper around the accumulator value of the traversal function, which will
  avoid recursive decent from this node on.
  """
  defstruct acc: "boxed accumulator"
  def me?(%__MODULE__{}), do: true
  def me?(_), do: false
end
