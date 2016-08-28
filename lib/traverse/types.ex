defmodule Traverse.Types do

  defmacro __using__(_options \\ []) do
    quote do
      @type t_next :: {any} | {any, traverse_fn}
      @type traverse_fn :: (any, any -> t_next)

      @type t_parent      :: :list | :map | :tuple | nil
      @type t_simple_walker_fn :: (any, any -> any)
      @type t_structure_fn :: (any -> any)
      @type t_traverse_fn :: ({any, t_parent}, any -> t_next)
    end
  end

end
