defmodule Traverse do

  use Traverse.Types
  use Traverse.Macros

  defmodule Cut do 
    @moduledoc """
    A wrapper around the accumulator value of the traversal function, which will
    avoid recursive decent from this node on.
    """
    defstruct acc: "boxed accumulator"
  end

  @moduledoc """
  ## Traverse is a toolset to walk arbitrary Elixir Datastructures.

  `walk` visits all substructures down to atomic elements.

      iex>    ds = [:a, {:b, 1, 2}, [:c, 3, 4, 5]]
      ...>    collector =  fn ele, acc when is_atom(ele) or is_number(ele) -> [ele|acc]
      ...>                    _,   acc                    -> acc       end
      ...>    Traverse.walk(ds, [], collector)
      [5, 4, 3, :c, 2, 1, :b, :a]

   One can return the accumulator boxed in a `%Cut{}` struct to avoid traversal of the
   subtree.

      iex>   ds = [add: [1, 2], ignore: [3, 4]]
      ...>   collector = fn {:ignore, _}, acc        -> %Traverse.Cut{acc: acc}
      ...>                  n, acc when is_number(n) -> [n|acc]
      ...>                  _, acc                   -> acc end
      ...>   Traverse.walk(ds, [], collector)
      [2, 1]
  """

  @spec walk( any, any, t_simple_walker_fn ) :: any
  def walk( ds, initial_acc, walker_fn ), 
    do: Traverse.Walker.walk(ds, initial_acc, walker_fn)

end
