defmodule Traverse do

  use Traverse.Types

  @moduledoc """
  Implements traversal of Enumerables and Tuples à la `Enum.reduce`.

  A simple `pre_walk` might deliver the following:

  iex>    ds = [:a, {:b, 1, 2}, [:c, 3, 4, 5]]
  ...>    collector =  fn ele, acc when is_atom(ele) or is_number(ele) -> [ele|acc]
  ...>                    _,   acc                    -> acc       end
  ...>    Traverse.pre_walk(ds, [], collector)
  [5, 4, 3, :c, 2, 1, :b, :a]

  However one might get surprised that the `post_walk` trabversal yields the same result

  iex>    ds = [:a, {:b, 1, 2}, [:c, 3, 4, 5]]
  ...>    collector =  fn ele, acc when is_atom(ele) or is_number(ele) -> [ele|acc]
  ...>                    _,   acc                    -> acc       end
  ...>    Traverse.post_walk(ds, [], collector)
  [5, 4, 3, :c, 2, 1, :b, :a]

  The explanation for this is the simple fact that a datastructure has no semantic meaning, we
  might think that it represents a tree in this form:

        tree = [node, tree, tree...]

  but that semantic is unknown to both, the datastructure itself and the traversal function.

  Therefore if we want to have the _logical_ result of `[:a, :c, 3, 4, 5, :b, 2, 1]` from a **post**
  traversal we have to inform the traversal of the structure.

  The most general way is to use a structural function that, when applied to a node returns a list of the form
  `[node, tree, tree...]`. We can than traverse as follows

  iex>    ds = [:a, {:b, 1, 2}, [:c, 3, 4, 5]]
  ...>    structurer = fn (tuple) when is_tuple(tuple) -> Tuple.to_list(tuple)
  ...>                    anything                     -> anything end
  ...>    collector =  fn ele, acc when is_atom(ele) or is_number(ele) -> [ele|acc]
  ...>                    _,   acc                    -> acc       end
  ...>    Traverse.post_traverse(ds, [], collector, structurer)
  [:a, :c, 5, 4, 3, :b, 2, 1]

  `pre_traverse` behaves identical to `*_walk`

  iex>    ds = [:a, {:b, 1, 2}, [:c, 3, 4, 5]]
  ...>    structurer = fn (tuple) when is_tuple(tuple) -> Tuple.to_list(tuple)
  ...>                    anything                     -> anything end
  ...>    collector =  fn ele, acc when is_atom(ele) or is_number(ele) -> [ele|acc]
  ...>                    _,   acc                    -> acc       end
  ...>    Traverse.pre_traverse(ds, [], collector, structurer)
  [5, 4, 3, :c, 2, 1, :b, :a]
  """

  @spec post_traverse( any, any, t_simple_walker_fn, t_structure_fn ) :: any
  def post_traverse(ds, initial_acc, traverser, structurer),
    do: Traverse.Traverser.post_traverse(ds, initial_acc, traverser, structurer)
    
  @spec post_walk( any, any, t_simple_walker_fn ) :: any
  def post_walk( ds, initial_acc, walker_fn ), 
    do: Traverse.Walker.simple_post_walk(ds, initial_acc, walker_fn)

  @spec pre_traverse( any, any, t_simple_walker_fn, t_structure_fn ) :: any
  def pre_traverse( ds, initial_acc, traverser, structurer ),
    do: Traverse.Traverser.pre_traverse(  ds, initial_acc, traverser, structurer )

  @spec pre_walk( any, any, t_simple_walker_fn ) :: any
  def pre_walk( ds, initial_acc, walker_fn ), 
    do: Traverse.Walker.simple_pre_walk(ds, initial_acc, walker_fn)

end
