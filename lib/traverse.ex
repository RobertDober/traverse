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
  ...>    Traverse.traverse(ds, 0, collect)
  24

  That might come as a surprise as we expected rather 42, but traversing a
  map gives us tuples and we traverse the values of these tuples with the
  `simple` function above.

  This can be avoided by means of a more complicated traversing logic of course
  or by using the more explicit API of `traverse_t` which stands for _traverse_
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
  ...>    Traverse.traverse_t(ds, 0, collect)
  42
  """

  @spec traverse( any, any, traverse_fn ) :: any
  def traverse( coll, acc, collector ) 

  def traverse( ele, acc, collector ) when is_tuple(ele) do
    with {acc, fun} <- collector.(ele, acc) |> add_default_fun(collector) do
      ele
      |> Tuple.to_list()
      |> Enum.reduce( acc, &(traverse(&1, &2, fun) ) )
    end
  end

  def traverse( ele, acc, collector) when is_list(ele) do
    with {acc, fun} <- collector.(ele, acc) |> add_default_fun(collector) do
      ele
      |> Enum.reduce( acc, &(traverse(&1, &2, fun) ) )
    end
  end

  def traverse( ele, acc, collector ) when is_map(ele) do
    with {acc, fun} <- collector.(ele, acc) |> add_default_fun(collector) do
      ele
      |> Enum.reduce( acc, &(traverse(&1, &2, fun) ) )
    end
  end

  def traverse( ele, acc, collector ) do
    with {acc, _} <- collector.(ele, acc) |> add_default_fun(collector), do: acc
  end

  @spec traverse_t( any, any, traverse_t_fn ) :: any
  def traverse_t( coll, acc, collector ), do: _traverse_t(coll, acc, collector, nil) 

  defp _traverse_t( ele, acc, collector, parent_t ) when is_tuple(ele) do
    with {acc, fun} <- collector.({ele, parent_t}, acc) |> add_default_fun(collector) do
      ele
      |> Tuple.to_list()
      |> Enum.reduce( acc, &(_traverse_t(&1, &2, fun, :tuple) ) )
    end
  end

  defp _traverse_t( ele, acc, collector, parent_t) when is_list(ele) do
    with {acc, fun} <- collector.({ele, parent_t}, acc) |> add_default_fun(collector) do
      ele
      |> Enum.reduce( acc, &(_traverse_t(&1, &2, fun, :list) ) )
    end
  end

  defp _traverse_t( ele, acc, collector, parent_t ) when is_map(ele) do
    with {acc, fun} <- collector.({ele, parent_t}, acc) |> add_default_fun(collector) do
      ele
      |> Enum.reduce( acc, &(_traverse_t(&1, &2, fun, :map) ) )
    end
  end

  defp _traverse_t( ele, acc, collector, parent_t ) do
    with {acc, _} <- collector.({ele, parent_t}, acc) |> add_default_fun(collector), do: acc
  end

  @doc """
  It is not always simple to debug the logic of so many functions passed around, the
  `_traverse_trace` wrapper can help quite a bit in these cases
  """
  def traverse_trace( coll, acc, collector) do
    with f <- fn e, a -> IO.puts ">>> #{inspect e}, #{inspect a}"
                  r = collector.(e, a)
                  IO.puts "<<< #{inspect r}"
                  r
    end, do: traverse(coll, acc, f)

  end
  defp add_default_fun({acc}, fun), do: {acc, fun}
  defp add_default_fun({acc, fun}, _), do: {acc, fun}
end
