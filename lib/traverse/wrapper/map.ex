defmodule Traverse.Wrapper.Map do
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
end
