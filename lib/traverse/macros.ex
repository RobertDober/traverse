defmodule Traverse.Macros do
  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
    end
  end

  @moduledoc """
  Useful shortcuts for traversal and structure functions.
  """

  @doc """
    Very often, traversal and structure functions need to distinguish on this type of argument, e.g.

        fn ...
           (ele, acc) when is_scalar(ele) -> some_update(ele, acc)

  """
  defmacro is_scalar(x) do
    quote bind_quoted: [x: x] do
      is_atom(x) or is_number(x) or is_binary(x)
    end
  end
end
