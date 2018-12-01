defmodule Traverse.Mapper do
  use Traverse.Types

  import Traverse.Enum, only: [reduce: 3]

  @moduledoc """
    Implements structure perserving transformations on arbitrary data structures
  """

  @doc """
    Implements `Traverse.map`
  """
  @spec map(any, t_simple_mapper_fn) :: any
  def map(ds, transformer)

  def map(ds, transformer) when is_list(ds) do
    ds
    |> Enum.map(&map(&1, transformer))
    |> Enum.reject(&Traverse.Ignore.me?/1)
  end

  def map(ds, transformer) when is_tuple(ds) do
    ds
    |> Tuple.to_list()
    |> Enum.map(&map(&1, transformer))
    |> Enum.reject(&Traverse.Ignore.me?/1)
    |> List.to_tuple()
  end

  def map(%{__struct__: type} = ds, transformer) do
    ds
    |> Map.delete(:__struct__)
    |> map(transformer)
    |> Map.put(:__struct__, type)
  end

  def map(ds, transformer) when is_map(ds) do
    ds
    |> reduce(Map.new(), fn {key, value}, acc ->
      val = map(value, transformer)

      if Traverse.Ignore.me?(val) do
        acc
      else
        Map.put(acc, key, val)
      end
    end)
  end

  def map(scalar, transformer), do: transformer.(scalar)

  @spec map(any, t_simple_mapper_fn) :: any
  def map!(ds, transformer), do: map(ds, wrapped(transformer))

  @doc """
    Implementation of `Traverse.mapall`
  """
  @spec mapall(any, t_simple_mapper_fn, boolean) :: any
  def mapall(ds, transformer, post) do
    if post do
      ds
      |> mapall_post(transformer)
    else
      ds
      |> mapall_pre(transformer)
    end
  end

  #
  # POST
  #

  defp mapall_post(list, transformer) when is_list(list) do
    list
    |> Enum.map(&mapall_post(&1, transformer))
    |> Enum.reject(&Traverse.Ignore.me?/1)
    |> wrapped(transformer).()
  end

  defp mapall_post(tuple, transformer) when is_tuple(tuple) do
    tuple
    |> Tuple.to_list
    |> Enum.map(&mapall_post(&1, transformer))
    |> Enum.reject(&Traverse.Ignore.me?/1)
    |> List.to_tuple
    |> wrapped(transformer).()
  end

  defp mapall_post(%{__struct__: type}=ds, transformer) do
    ds
    |> Map.delete(:__struct__)
    |> mapall_post(transformer)
  end

  defp mapall_post(ds, transformer) when is_map(ds) do
    ds
    |> Enum.reduce(Map.new(), fn {key, value}, acc ->
      val = mapall_post(value, transformer)

      if Traverse.Ignore.me?(val) do
        wrapped(transformer).(acc)
      else
        wrapped(transformer).(Map.put(acc, key, val))
      end
    end)
  end

  defp mapall_post(scalar, transformer), do: transformer.(scalar)

  #
  # PRE
  #

  defp mapall_after_transform(ds, transformer) when is_list(ds) do
    ds
    |> Enum.map(&mapall_pre(&1, transformer))
    |> Enum.reject(&Traverse.Ignore.me?/1)
  end

  defp mapall_after_transform(%{__struct__: type}=ds, transformer) do
    ds
    |> Map.delete(:__struct__)
    |> mapall_after_transform(transformer)
    |> Map.put(:__struct__, type)
  end

  defp mapall_after_transform(ds, transformer) when is_map(ds) do
    ds
    |> Enum.reduce(Map.new(), fn {key, value}, acc ->
      val = mapall_pre(value, transformer)

      if Traverse.Ignore.me?(val) do
        acc
      else
        Map.put(acc, key, val)
      end
    end)
  end

  defp mapall_after_transform(ds, transformer) when is_tuple(ds) do
    ds
    |> Tuple.to_list()
    |> Enum.map(&mapall_pre(&1, transformer))
    |> Enum.reject(&Traverse.Ignore.me?/1)
    |> List.to_tuple()
  end

  defp mapall_after_transform(ds, transformer) do
    transformer.(ds)
  end

  defp mapall_pre(ds, transformer)
       when is_list(ds) or is_map(ds) or is_tuple(ds) do
    ds
    |> wrapped(transformer).()
    |> mapall_after_transform(transformer)
  end

  defp mapall_pre(ds, transformer), do: transformer.(ds)

  defp wrapped(fun) do
    fn arg ->
      try do
        fun.(arg)
      rescue
        FunctionClauseError -> arg
      end
    end
  end
end
