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

  defmodule Ignore do
    @moduledoc """
      When a transformer function returns this value the transformation of the
      containing datastructure will not contain it, in case the containing datastructure is
      a map the key is omitted in the transformation.

      iex> Traverse.map([1, 2, %{a: 1}, {1, 2}], fn _ -> Traverse.Ignore end)
      [%{}, {}]
    """
    @doc """
      Lackmus to decide if an argument is to be ignored, or, in other words, is me.
    """
    def me?(__MODULE__), do: true
    def me?(_), do: false
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

  @spec filter( any, t_simple_filter_fn ) :: any
  def filter(ds, filter_fn),
    do: Traverse.Mapper.filter(ds, filter_fn)

  @spec map( any, t_simple_mapper_fn ) :: any
  def map( ds, mapper_fn ),
    do: Traverse.Mapper.map(ds, mapper_fn)

  @doc """
    `mapall` like `map` perserves the structure of the datastructure passed in.

    However it also calls the `transformer` function for inner nodes, which allows
    us to perform mappings on substructures.

    Again the `transformer` function can be partially defined and is completed by
    the identity function.

    And, also again, the special return value `Traverse.Ignore` can be used to ignore
    values or substructures.

    Here is a simple example that eliminates empty sublists

    iex> [1, [[]], 2, [3, []]]
    ...> |> Traverse.mapall(fn [] -> Traverse.Ignore end)
    [1, [], 2, [3]]

    This example shows that `mapall` applies a prewalk strategy by default, we can
    change this by providing the option `post: true`.

    iex> [1, [[]], 2, [3, []]]
    ...> |> Traverse.mapall(fn [] -> Traverse.Ignore end, post: true)
    [1, 2, [3]]
    
    Now, by applying the transformation after having transformed the substructure, empty lists
    of empty lists go away too.
  """
  @spec mapall( any, t_simple_mapper_fn, Keyword.t ) :: any
  def mapall( ds, mapper_fn , options \\ []),
    do: Traverse.Mapper.mapall(ds, mapper_fn, Keyword.get(options, :post, false))
end
