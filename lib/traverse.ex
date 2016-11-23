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

  @doc """
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

  @doc """
    filter allows to filter arbitrary substructures according to a filter function.

    The filter function does not need to be completely defined, undefined values
    are mapped to false. In other words we need to define the filter functions only
    for structures and values we want to keep.

        iex> number_arrays = fn x when is_number(x) -> true
        ...>                    l when is_list(l)   -> true end
        ...> Traverse.filter([:a, {1, 2}, 3, [4, :b]], number_arrays)
        [3, [4]]

    The same result can be achieved with `mapall` and `Traverse.Ignore` if that suits
    your style better:

        iex> not_number_arrays = fn x when is_number(x) or is_list(x) -> x
        ...>                    _   -> Traverse.Ignore end
        ...> Traverse.mapall([:a, {1, 2}, 3, [4, :b]], not_number_arrays)
        [3, [4]]

  """
  @spec filter( any, t_simple_filter_fn ) :: any
  def filter(ds, filter_fn),
    do: Traverse.Filter.filter(ds, filter_fn)

  @doc """
    map preserves structure, that is lists remain lists, tuples remain tuples and
    maps remain maps with the same keys, unless the transformation returns `Traverse.Ignore` (c.f. `map1` if you want to transform key
    value pairs in maps)

    In order to avoid putting unnecessary burden on the transformer function it can only be partially defined, and it will be completed
    with the identity function for undefined parameters. Here is an example.

        iex> Traverse.map([:a, 1, {:b, 2}], fn x when is_number(x) -> x + 1 end)
        [:a, 2, {:b, 3}]

    The transformer function can also return the special value `Traverse.Ignore`, which will remove the value from the result, and in
    case of a map it will remove the key, value pair.

        iex> require Integer
        ...> no_odds = fn x when Integer.is_even(x) -> x * 2
        ...>              _                 -> Traverse.Ignore end
        ...> Traverse.map([1, %{a: 1, b: 2}, {3, 4}], no_odds)
        [%{b: 4}, {8}]

    The more general way to achieve this is to use `filter_map`, which however is less efficent as the filter function is also called
    on inner nodes.
  """
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

  # @doc """
  #   `zipfn` augments each node and leaf in the datastructure, replacing it with the pair
  #   containing its original value and the result of the function applied to the node.

  #   As very often we will be interested in only some specific values we can, as usually,
  #   define a partial zip function, the `default` value is used to complete the zip
  #   function with a constant function returning this value, the `default` defaults to nil.

  #   iex> Tranverse.zip([1, {:a, 2}, %{b: 3, c: "hello"}],
  #   ...>   fn x when is_number(x) -> x + 1 end)
  #   [{1, 2}, {a: 2]end
    
  # """
  # @spec zip( any, t_simple_mapper_fn, any ) :: any
  # def zip(ds, zipfn, default \\ nil)
end
