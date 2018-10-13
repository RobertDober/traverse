defmodule Support.EnumStruct do
  use Traverse.Implementations.Enum

  defstruct alpha: "The first",
            omega: "The last"
end
