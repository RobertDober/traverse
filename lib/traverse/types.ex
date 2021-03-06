defmodule Traverse.Types do
  defmacro __using__(_options \\ []) do
    quote do
      @type t_simple_filter_fn :: (any -> boolean)
      @type t_simple_mapper_fn :: (any -> any)
      @type t_simple_walker_fn :: (any, any -> any)
      @type t_traceable_fn :: (any -> any) | (any, any -> any) | (any, any, any -> any)
    end
  end
end
