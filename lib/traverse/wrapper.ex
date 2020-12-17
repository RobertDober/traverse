defmodule Traverse.Wrapper do
  @type t :: Traverse.Wrapper.List.t() | Traverse.Wrapper.Map.t() | Traverse.Wrapper.Struct.t() | Traverse.Wrapper.Tuple.t()
end
