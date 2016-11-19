defmodule Traverse.Mapper do
  
  use Traverse.Types

  @moduledoc """
    Implements structure perserving transformations on arbitrary data structures
  """

  @doc """
    map preserves structure, that is lists remain lists, tuples remain tuples and
    maps remain maps with the same keys, unless the transformation returns `Traverse.Ignore` (c.f. `map1` if you want to transform key
    value pairs in maps)

    Thusly 
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
  def map(scalar, transformer), do: transformer.(scalar)

end
