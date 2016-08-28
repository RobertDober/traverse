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
    quote do
      is_atom(unquote(x)) or is_number(unquote(x)) or is_binary(unquote(x))
    end
  end
end
