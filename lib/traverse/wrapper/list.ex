defmodule Traverse.Wrapper.List do
  use Traverse.Types
  @type t :: %__MODULE__{content: list()}

  @moduledoc """
  A wrapper object of a list for the input stack, allowing its non recursive traversal 
  """
  defstruct content: []

  @spec new(list()) :: t
  def new(content \\ []) when is_list(content), do: %__MODULE__{content: content}

  @spec pop([t|list()], module) :: {list(), module()}
  def pop(stack, visitor)
  def pop([%__MODULE__{content: []}|rest], visitor) do
    visitor.close_list
    {rest, visitor}
  end
  def pop([%__MODULE__{content: [h|t]}|rest], visitor) do
    {[h, new(t) | rest], visitor}
  end

  @spec red([t|list()], any(), reducer_t(), Keyword.t()) :: reducer_tuple()
  def red(stack, accumulator, reducer, opts)
  def red([%__MODULE__{content: []}|rest], accumulator, reducer, opts) do
    acc1 = reducer.({:close_list, nil}, accumulator)
    {rest, acc1, reducer, opts}
  end
  def red([%__MODULE__{content: [h|t]}|rest], accumulator, reducer, opts) do
    {[h, %__MODULE__{content: t} | rest], accumulator, reducer, opts}
  end
end

