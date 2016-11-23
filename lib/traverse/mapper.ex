defmodule Traverse.Mapper do

  use Traverse.Types

  @moduledoc """
    Implements structure perserving transformations on arbitrary data structures
  """

  @doc """
    filter allows to filter arbitrary substructures according to a filter function.

    The filter function does not need to be completely defined, undefined values
    are mapped to false. In other words we need to define the filter functions only
    for structures and values we want to keep.

        # iex> number_arrays = fn x when is_number(x) -> true
        # ...>                    l when is_list(l)   -> true end
        # ...> Traverse.filter([:a, {1, 2}, 3, [4, :b]], number_arrays)

  """
  @spec filter( any, t_simple_filter_fn ) :: any
  def filter(ds, filter_fn)

  def filter(ds, filter_fn) when is_list(ds) do
    ds
    |> Enum.reduce([], fn ele, acc ->
      if filter(ele, filter_fn) do
        [ele | acc]
      else
        acc
      end
    end)
    |> Enum.reverse()
  end
  def filter(ds, filter_fn) when is_tuple(ds) do
    ds
    |> Tuple.to_list()
    |> filter(filter_fn)
    |> List.to_tuple()
  end
  def filter(ds, filter_fn) when is_map(ds) do
    ds
    |> Enum.reduce(%{}, fn {k, v}, acc ->
      if filter({k, v}, filter_fn) do
        Map.put(acc, k, v)
      else
        acc
      end
    end)
  end
  def filter(ds, filter_fn), do: wrapped_call(filter_fn, ds, false)


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
  def map(ds, transformer)

  def map(ds, transformer) when is_list(ds) do
    Enum.map(ds, &map(&1, transformer))
    |> Enum.reject(&Traverse.Ignore.me?/1)
  end
  def map(ds, transformer) when is_tuple(ds) do
    ds
    |> Tuple.to_list()
    |> Enum.map(&map(&1, transformer))
    |> Enum.reject(&Traverse.Ignore.me?/1)
    |> List.to_tuple()
  end
  def map(ds, transformer) when is_map(ds) do
    ds |>
    Enum.reduce(Map.new, fn {key, value}, acc ->
      val = map(value, transformer)
      if Traverse.Ignore.me?(val) do
        acc
      else
        Map.put(acc, key, val)
      end
    end)
  end
  def map(scalar, transformer), do: wrapped_call(transformer, scalar)

  @doc """
    Implementation of `Traverse.mapall`
  """
  @spec mapall( any, t_simple_mapper_fn, boolean ) :: any
  def mapall(ds, transformer, post) do
    with complete_transformer = complete_fn(transformer, fn x -> x end) do
      if post do
        ds
        |> mapall_postelements(complete_transformer)
      else
        ds
        |> mapall_preelements(complete_transformer)
      end
    end
  end

  #
  # POST
  #
  defp mapall_post(ds, transformer) do
    ds
    |> mapall_postelements(transformer)
    |> transformer.()
  end

  defp mapall_postelements(list, transformer) when is_list(list) do
    list
    |> Enum.map(&mapall_post(&1, transformer))
    |> Enum.reject(&Traverse.Ignore.me?/1)
  end
  defp mapall_postelements(tuple, transformer) when is_tuple(tuple) do
    tuple
    |> Tuple.to_list()
    |> Enum.map(&mapall_post(&1, transformer))
    |> Enum.reject(&Traverse.Ignore.me?/1)
    |> List.to_tuple()
  end
  defp mapall_postelements(ds, transformer) when is_map(ds) do
      ds
      |> Enum.reduce(Map.new, fn {key, value}, acc ->
        val = mapall_post(value, transformer)
        if Traverse.Ignore.me?(val) do
          acc
        else
          Map.put(acc, key, val)
        end
      end)
  end
  defp mapall_postelements(scalar, transformer), do: scalar

  #
  # PRE
  #
  defp mapall_pre(ds, transformer) do
    ds
    |> transformer.()
    |> mapall_preelements(transformer)
  end
  defp mapall_preelements(ds, transformer) when is_list(ds) do
    ds
    |> Enum.map(&mapall_pre(&1, transformer))
    |> Enum.reject(&Traverse.Ignore.me?/1)
  end
  defp mapall_preelements(ds, transformer) when is_tuple(ds) do
    ds
    |> Tuple.to_list()
    |> Enum.map(&mapall_pre(&1, transformer))
    |> Enum.reject(&Traverse.Ignore.me?/1)
    |> List.to_tuple()
  end
  defp mapall_preelements(ds, transformer) when is_map(ds) do
      ds
      |> Enum.reduce(Map.new, fn {key, value}, acc ->
        val = mapall_pre(value, transformer)
        if Traverse.Ignore.me?(val) do
          acc
        else
          Map.put(acc, key, val)
        end
      end)
  end
  defp mapall_preelements(scalar, transformer), do: scalar

  defp complete_fn(fun, fallback) do
    fn x ->
      try do
        fun.(x)
      rescue
        FunctionClauseError -> fallback.(x)
      end
    end
  end

  defp wrapped_call(fun, arg), do: wrapped_call(fun, arg, arg)
  defp wrapped_call(fun, arg, default) do
    try do
      fun.(arg)
    rescue
      FunctionClauseError -> default
    end
  end

end
