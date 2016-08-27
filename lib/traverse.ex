defmodule Traverse do

  @type t_next :: {any} | {any, traverse_fn}
  @type traverse_fn :: (any, any -> t_next)

  @type t_parent      :: :list | :map | :tuple | nil
  @type traverse_t_fn :: ({any, t_parent}, any -> t_next)

  @moduledoc """
  Allows traversal of Enumerables and Tuples by means of functions. This is like `Enum.reduce`
  but with variable functions.
  This is implemented by a convention that the traversing function needs to wrap its return
  value into a Tuple and the, optional, second element of the tuple will replace the traversing
  function for the subtree, e.g.

  iex>    ds = [ 1, %{a: 2}, {3, 4, 5}]
  ...>    simple  = fn( ele, acc ) when is_number(ele) -> {acc + ele}
  ...>                ( _,   acc ) -> {acc} end
  ...>    collect = fn( ele, acc ) when is_tuple(ele)  ->  {acc, simple}
  ...>                ( ele, acc ) when is_number(ele) -> {acc + ele * 10}
  ...>                ( _,   acc )                     -> {acc} end
  ...>    Traverse.pre(ds, 0, collect)
  24

  That might come as a surprise as we expected rather 42, but traversing a
  map gives us tuples and we traverse the values of these tuples with the
  `simple` function above.

  This can be avoided by means of a more complicated traversing logic of course
  or by using the more explicit API of `pre_t` which stands for _pre_
  _typed_.

  It will not pass `ele` into the traverse_fn, but `{ele, parent_type}`.
  
  In the case above, if we want to get 42 as a result, and who doesn't, we
  can take advantage of it as follows:

  iex>    ds = [ 1, %{a: 2}, {3, 4, 5}]
  ...>    simple  = fn( {ele, _}, acc ) when is_number(ele) -> {acc + ele}
  ...>                ( _,   acc ) -> {acc} end
  ...>    collect = fn( {ele, :map}, acc ) when is_tuple(ele) ->  {acc}
  ...>                ( {ele, _}, acc ) when is_tuple(ele)  ->  {acc, simple}
  ...>                ( {ele, _},  acc ) when is_number(ele) -> {acc + ele * 10}
  ...>                ( _,   acc )                     -> {acc} end
  ...>    Traverse.pre_t(ds, 0, collect)
  42
  """

  @doc """
  `pre` traverses a datastructure in preorder, updating an accumulator value and allowing to change the traversal function for the substructure to
  be traversed. As a matter of fact, if the traverse_fn returns a tuple with only one value, this value becomes the new accumulator and traversal
  continues with traverse_fn. However if traverse_fn returns a pair `{acc, new_fun}`, the substructure is traversed using `new_fun`.
  example:
  
  iex>   ds = [1, {2, {3}}, {4}]
  ...>   make_new_fun = fn (multiplier, self) ->
  ...>     fn (ele, acc) when is_number(ele)  -> { acc + ele * multiplier}
  ...>        (tpl, acc) when is_tuple(tpl)   -> { acc, self.(multiplier + 1, self)}
  ...>        (_,   acc)                      -> { acc } end
  ...>   end
  ...>   Traverse.pre(ds, 0, make_new_fun.(1, make_new_fun))
  22 

  This can also be used to cut substructures

  iex>  ds = %{ ignore: [1, 2], other: [3, 4] } 
  ...>  sum = fn ({:ignore, _}, acc) -> {acc, Traverse.Tools.acc_for_pre}
  ...>           (n, acc) when is_number(n) -> {acc + n}
  ...>           _, acc                     -> { acc } end
  ...>  Traverse.pre(ds, 0, sum)
  7

  """
  @spec pre( any, any, traverse_fn ) :: any
  def pre( coll, acc, collector ) 

  def pre( ele, acc, collector ) when is_tuple(ele) do
    with {acc, fun} <- collector.(ele, acc) |> add_default_fun(collector) do
      ele
      |> Tuple.to_list()
      |> Enum.reduce( acc, &(pre(&1, &2, fun) ) )
    end
  end

  def pre( ele, acc, collector) when is_list(ele) do
    with {acc, fun} <- collector.(ele, acc) |> add_default_fun(collector) do
      ele
      |> Enum.reduce( acc, &(pre(&1, &2, fun) ) )
    end
  end

  def pre( ele, acc, collector ) when is_map(ele) do
    with {acc, fun} <- collector.(ele, acc) |> add_default_fun(collector) do
      ele
      |> Enum.reduce( acc, &(pre(&1, &2, fun) ) )
    end
  end

  def pre( ele, acc, collector ) do
    with {acc, _} <- collector.(ele, acc) |> add_default_fun(collector), do: acc
  end

  @doc """
  This is like `pre` but `traverse_fn` gets assitional information about the immediate parent, which is
  `nil` for the first level, and `:list`, `:tuple` or `:map` for anything else.
  
  As a first example we can rewrite the above example not incrementing the multiplier when already inside a tuple:
  
  iex>   ds = [1, {2, {3}}, {4}]
  ...>   make_new_fun = fn (multiplier, self) ->
  ...>     fn ({ele, _}, acc)      when is_number(ele)  -> { acc + ele * multiplier}
  ...>        ({tpl, :tuple}, acc) when is_tuple(tpl)   -> { acc }
  ...>        ({tpl, _}, acc)      when is_tuple(tpl)   -> { acc, self.(multiplier + 1, self)}
  ...>        (_,   acc)                                -> { acc } end
  ...>   end
  ...>   Traverse.pre_t(ds, 0, make_new_fun.(1, make_new_fun))
  19 

  This might seem a bit overengineered, until you discover that traversing maps and keyword lists gives you...
  **tuples**

  iex>   ds = [ {2, 3}, %{ 4 => 2, 3 => 3}]
  ...>   treat_map = fn {{lhs, rhs}, _}, acc -> { acc + lhs * rhs }
  ...>                  _, acc               -> { acc } end
  ...>   treat_tuple = fn {x, _}, acc  when is_number(x) -> {acc + x}
  ...>                     _, acc                        -> {acc} end
  ...>   Traverse.pre_t_trace(ds, 0, fn {{l, r}, :map}, acc  -> {acc + l*r, Traverse.Tools.acc_for_pre}
  ...>                                  {{l, r}, _}, acc     -> {acc + l + r, Traverse.Tools.acc_for_pre}
  ...>                                  _, acc               -> {acc} end)
  22
  """
  @spec pre_t( any, any, traverse_t_fn ) :: any
  def pre_t( coll, acc, collector ), do: _pre_t(coll, acc, collector, nil) 

  defp _pre_t( ele, acc, collector, parent_t ) when is_tuple(ele) do
    with {acc, fun} <- collector.({ele, parent_t}, acc) |> add_default_fun(collector) do
      ele
      |> Tuple.to_list()
      |> Enum.reduce( acc, &(_pre_t(&1, &2, fun, :tuple) ) )
    end
  end

  defp _pre_t( ele, acc, collector, parent_t) when is_list(ele) do
    with {acc, fun} <- collector.({ele, parent_t}, acc) |> add_default_fun(collector) do
      ele
      |> Enum.reduce( acc, &(_pre_t(&1, &2, fun, :list) ) )
    end
  end

  defp _pre_t( ele, acc, collector, parent_t ) when is_map(ele) do
    with {acc, fun} <- collector.({ele, parent_t}, acc) |> add_default_fun(collector) do
      ele
      |> Enum.reduce( acc, &(_pre_t(&1, &2, fun, :map) ) )
    end
  end

  defp _pre_t( ele, acc, collector, parent_t ) do
    with {acc, _} <- collector.({ele, parent_t}, acc) |> add_default_fun(collector), do: acc
  end

  @doc """
  It is not always simple to debug the logic of so many functions passed around, the
  `_pre_trace` wrapper can help quite a bit in these cases
  """
  def pre_trace( coll, acc, collector), do: pre(coll, acc, make_trace_fun(collector))

  @doc """
  Same tracing variant for `pre_t`.
  """
  def pre_t_trace( coll, acc, collector), do: pre_t(coll, acc, make_trace_fun(collector))

  defp make_trace_fun fun do
    with f <- fn e, a -> IO.puts ">>> #{inspect e}, #{inspect a}"
                  r = fun.(e, a)
                  IO.puts "<<< #{inspect r}"
                  r
    end, do: f
  end

  defp add_default_fun({acc}, fun), do: {acc, fun}
  defp add_default_fun({acc, fun}, _), do: {acc, fun}
end
