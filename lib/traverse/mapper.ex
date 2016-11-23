defmodule Traverse.Mapper do

  use Traverse.Types

  @moduledoc """
    Implements structure perserving transformations on arbitrary data structures
  """

  @doc """
    Implements `Traverse.map`
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
  defp mapall_postelements(scalar, _transformer), do: scalar

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
  defp mapall_preelements(scalar, _transformer), do: scalar

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
