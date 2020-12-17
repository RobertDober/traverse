defmodule Traverse.Wrapper.Tuple do
  use Traverse.Types

  @type t :: %__MODULE__{content: list()}

  @moduledoc """
  A wrapper object of a tuple for the input stack, allowing its non recursive traversal 
  """
  defstruct content: []


  @spec new(tuple()) :: t
  def new(content) when is_tuple(content), do: %__MODULE__{content: Tuple.to_list(content)}

  @spec pop([t|list()], module) :: {list(), module()}
  def pop(stack, visitor)
  def pop([%__MODULE__{content: []}|rest], visitor) do
    visitor.close_tuple
    {rest, visitor}
  end
  def pop([%__MODULE__{content: [h|t]}|rest], visitor) do
    {[h, %__MODULE__{content: t} | rest], visitor}
  end

  @spec red([t|list()], any(), reducer_t()) :: reducer_triple()
  def red(stack, accumulator, reducer)
  def red([%__MODULE__{content: []}|rest], accumulator, reducer) do
    acc1 = reducer.({:close_tuple, nil}, accumulator)
    {rest, acc1, reducer}
  end
  def red([%__MODULE__{content: [h|t]}|rest], accumulator, reducer) do
    {[h, %__MODULE__{content: t} | rest], accumulator, reducer}
  end
end
