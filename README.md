# Traverse

![CI](https://github.com/RobertDober/traverse/workflows/CI/badge.svg)
[![Coverage Status](https://coveralls.io/repos/github/RobertDober/traverse/badge.svg?branch=master)](https://coveralls.io/github/RobertDober/traverse?branch=master)
[![Hex.pm](https://img.shields.io/hexpm/v/traverse.svg)](https://hex.pm/packages/traverse)
[![Inline docs](http://inch-ci.org/github/RobertDober/traverse.svg?branch=master)](http://inch-ci.org/github/RobertDober/traverse)
<!-- moduledoc: Traverse -->
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
<!-- endmoduledoc: Traverse -->


<!-- moduledoc: Traverse.Enum -->
  ## Traverse.Enum offers some extension functions for Elixir's Enum module
  
  ### Grouped Accumulation

  Groupes accumulated values of an Enum according to a function that
  indicates if two consequent items are of the same kind and if so
  how to accumulate their two values.

  The `grouped_reduce` function returns the groupes in reverse order, as,
  during traversal of lists quite often reversing the result of the 
  classical "take first and push a function of it to the result" pattern
  cancels out.
  
  An optional, `reverse: true` keyword option can be provided to reverse
  the final result for convenience.

      iex> add_same = fn {x, a}, {y, b} ->
      ...>               cond do
      ...>                 x == y -> {:cont, {x, a + b}}
      ...>                  true   -> {:stop, nil} end end
      ...> E.grouped_reduce(
      ...>   [{:a, 1}, {:a, 2}, {:b, 3}, {:b, 4}], add_same)
      [{:b, 7}, {:a, 3}]

  The `grouped_inject` function behaves almost identically to `grouped_reduce`,
  however an initial value is provided


      iex> sub_same = fn {x, a}, {y, b} -> 
      ...>               cond do
      ...>                 x == y -> {:cont, {x, a - b}}
      ...>                 true   -> {:stop, nil}
      ...>               end
      ...>            end
      ...> E.grouped_inject(
      ...> [{:a, 1}, {:b, 2}, {:b, 2}, {:c, 2}, {:c, 1}, {:c, 1}],
      ...>  {:a, 43}, sub_same, reverse: true)
      [a: 42, b: 0, c: 0]

<!-- endmoduledoc: Traverse.Enum -->
## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `traverse` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:traverse, "~> 0.1.0"}]
    end
    ```

  2. Ensure `traverse` is started before your application:

    ```elixir
    def application do
      [applications: [:traverse]]
    end
    ```

