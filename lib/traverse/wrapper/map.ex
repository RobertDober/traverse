defmodule Traverse.Wrapper.Map do
  use Traverse.Types
  @type t :: %__MODULE__{content: list()}

  @moduledoc """
  A wrapper object of a map for the input stack, allowing its non recursive traversal 
  """
  defstruct content: []

  @spec new(map()) :: t
  def new(content) when is_map(content), do: %__MODULE__{content: Map.to_list(content)}

  @spec pop([t|list()], module()) :: {list(), module()}
  def pop(stack, visitor)
  def pop([%__MODULE__{content: []}|rest], visitor) do
    visitor.close_map
    {rest, visitor}
  end
  def pop([%__MODULE__{content: [h|t]}|rest], visitor) do
    {[h, %__MODULE__{content: t} | rest], visitor}
  end

  @spec red([t|list()], any(), reducer_t(), Keyword.t()) :: reducer_tuple()
  def red(stack, accumulator, reducer, opts)
  def red([%__MODULE__{content: []}|rest], accumulator, reducer, opts) do
    acc1 = reducer.({:close_tuple, nil}, accumulator)
    {rest, acc1, reducer, opts}
  end
  def red([%__MODULE__{content: [h|t]}|rest], accumulator, reducer, opts) do
    tpl = _extract_tuple(h, opts)
    {[tpl, %__MODULE__{content: t} | rest], accumulator, reducer, opts}
  end


  @spec _extract_tuple(pair_t(), Keyword.t()) :: pair_t() | singleton_t()
  defp _extract_tuple(tpl, opts) do
    if Keyword.get(opts, :ignore_keys) do
      case tpl do
        {_key, value} -> {value}
      end
    else
      tpl
    end
  end
end
