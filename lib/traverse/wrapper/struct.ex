defmodule Traverse.Wrapper.Struct do
  use Traverse.Types
  @type t :: %__MODULE__{content: list(), struct: maybe(module)}

  @moduledoc """
  A wrapper object of a struct for the input stack, allowing its non recursive traversal 
  """
  defstruct content: [], struct: nil

  @spec new(map()) :: t
  def new(content) when is_struct(content) do
    struct1 = content.__struct__
    content1 = 
      content
      |> Map.from_struct
      |> Map.to_list
    %__MODULE__{content: content1, struct: struct1}
  end

  @spec pop([t|list()], module()) :: {list(), module}
  def pop(stack, visitor)
  def pop([%__MODULE__{content: [], struct: struct}|rest], visitor) do
    visitor.close_struct(struct)
    {rest, visitor}
  end
  def pop([%__MODULE__{content: [h|t], struct: struct}|rest], visitor) do
    {[h, %__MODULE__{content: t, struct: struct} | rest], visitor}
  end
end

