defmodule Traverse do

  use Traverse.Types
  use Traverse.Macros

  @moduledoc """
  ## Traverse is a toolset to walk arbitrary Elixir Datastructures.

  It allows for _uninformed_ traversal and for _informed_ or _structured_ traversal
  as in trees.

  There are convenience implementations for trees and for ASTs.

  A simple `walk` might deliver the following:

      iex>    ds = [:a, {:b, 1, 2}, [:c, 3, 4, 5]]
      ...>    collector =  fn ele, acc when is_atom(ele) or is_number(ele) -> [ele|acc]
      ...>                    _,   acc                    -> acc       end
      ...>    Traverse.walk(ds, [], collector)
      [5, 4, 3, :c, 2, 1, :b, :a]

  As we can see there is no structural information available, the result is a flat list of scalars
  contained in the datastructure. 

  If we want to attach structure to a datastructure for the purpose of its traversal, `Traverse`
  gives us two means to do so.

  * Structural Traversal

  * Dynamic Traversal
  

  The explanation for this is the simple fact that a datastructure has no semantic meaning, we
  might think that it represents a tree in this form:

        tree = [node, tree, tree...]

  but that semantic is unknown to both, the datastructure itself and the traversal function.

  Therefore if we want to have the _logical_ result of `[:a, :c, 3, 4, 5, :b, 2, 1]` from a _post_
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

    This structural behavior is so common that it is the default implementation for `*_traverse`, as
    we can demonstrate here:

      iex>    ds = [:a, {:b, 1, 2}, [:c, %{maps: "are leaves"}]]
      ...>    collector =  fn ele, acc when is_atom(ele) or is_number(ele) or is_map(ele) ->
      ...>                                                  [ele|acc]
      ...>                    _,   acc                    -> acc       end
      ...>    Traverse.post_traverse(ds, [], collector)
      [:a, :c, %{maps: "are leaves"}, :b, 2, 1]
      
    Another major nuisance is the fact that we have to use guard causes and provide a function branch that is
    called on non leaf nodes, that is the `_, acc  -> acc` function branch above. However when we do not need
    to collect on non leaf nodes we could just specify the leaf node behavior, this is implemented in the
    `Traverse.pre_leaves` and `Traverse.post_leaves` functions. Again the default behavior of the structurer is
    to consider lists and tuples as non leaf nodes.


      iex>    ds = [:a, {:b, 1, 2}, [:c, 3, 4]]
      ...>    collector = fn ele, acc -> acc - ele end
      ...>    Traverse.pre_leaves(ds, 100, collector, Traverse.Tools.tuple_list_trees)
      90
  """

  @spec post_leaves( any, any, t_simple_walker_fn, t_structure_fn ) :: any
  def post_leaves( ds, initial_acc, traverser, structurer \\ Traverse.Tools.list_trees),
    do: Traverse.Traverser.post_leaves(ds, initial_acc, traverser, structurer)

  @spec post_traverse( any, any, t_simple_walker_fn, t_structure_fn ) :: any
  def post_traverse(ds, initial_acc, traverser, structurer \\ Traverse.Tools.list_trees),
    do: Traverse.Traverser.post_traverse(ds, initial_acc, traverser, structurer)
    
  @spec post_walk( any, any, t_simple_walker_fn ) :: any
  def post_walk( ds, initial_acc, walker_fn ), 
    do: Traverse.Walker.simple_post_walk(ds, initial_acc, walker_fn)

  @spec pre_leaves( any, any, t_simple_walker_fn, t_structure_fn ) :: any
  def pre_leaves( ds, initial_acc, traverser, structurer \\ Traverse.Tools.list_trees),
    do: Traverse.Traverser.pre_leaves(ds, initial_acc, traverser, structurer)

  @spec pre_traverse( any, any, t_simple_walker_fn, t_structure_fn ) :: any
  def pre_traverse( ds, initial_acc, traverser, structurer ),
    do: Traverse.Traverser.pre_traverse(  ds, initial_acc, traverser, structurer )

  @spec pre_walk( any, any, t_simple_walker_fn ) :: any
  def pre_walk( ds, initial_acc, walker_fn ), 
    do: Traverse.Walker.simple_pre_walk(ds, initial_acc, walker_fn)

end
