defmodule Traverse.Mapper do
  use Traverse.Types

  alias Traverse.Maker
  alias Traverse.Open
  alias Traverse.Pair

  import Traverse.Enum, only: [reduce: 3]

  @moduledoc """
  Implements structure perserving transformations on arbitrary data structures
  """


  @doc """
  Implements `Traverse.map`
  """
  @spec map(any, t_simple_mapper_fn) :: any
  def map(ds, transformer) do
    mapx([ds], transformer, [])
  end

  defp mapx(data, transformer, result) do
    IO.inspect({data, result})
    _map(data, transformer, result)
  end

  defp _map(data, transformer, result)
  defp _map([], _transformer, result), do: result |> List.first 
  defp _map([[]|rest], transformer, result) do
    IO.inspect(:empty_list)
    mapx(rest, transformer,[[]|result])
  end
  defp _map([%Pair{key: :__struct__}|rest], transformer, result) do
    IO.inspect(:ignore_struct)
    mapx(rest, transformer, result)
  end
  defp _map([%Pair{key: key, value: value}|rest], transformer, result) do
    IO.inspect(:pair)
    mapx([value|rest], transformer, [Maker.make_pair(key)|result])
  end
  defp _map([%{}=mp|rest], transformer, result) when mp == %{} do
    IO.inspect(:empty_map)
    mapx(rest, transformer, [%{}, result])
  end
  defp _map([%{}=mp|rest], transformer, result) do
    case _make_pairs(mp) do
      [h|t] -> mapx([h, Open.new(t)|rest], transformer, [Maker.make_map|result])
    end
  end
  defp _map([[h|t]|rest], transformer, result) do
    IO.inspect(:open_list)
    mapx([h,Open.new(t)|rest], transformer, [Maker.make_list|result])
  end
  defp _map([tpl|rest], transformer, result) when is_tuple(tpl) do
    IO.inspect(:tuple)
    case Tuple.to_list(tpl) do
      [] -> mapx(rest, transformer,[{}|result])
      [h|t] -> mapx([h, Open.new(t)|rest], transformer, [Maker.make_tuple|result])
    end
  end
  defp _map([%Open{data: []}|rest], transformer, result) do
    IO.inspect(:closing)
    mapx(rest, transformer, _close(result))
  end
  defp _map([%Open{}=open|rest], transformer, result) do
    IO.inspect(:pushing)
    {head, open_with_tail} = Open.pop(open)
    mapx([head, open_with_tail|rest], transformer, result)
  end
  defp _map([scalar|rest], transformer, result) do
    IO.inspect(:transforming)
    mapx(rest, transformer, [transformer.(scalar) | result])
  end

  defp _close(result, intermed \\ [])
  defp _close([], _intermed), do: raise(Traverse.InternalError, "_close did not find a maker on the stack")
  defp _close([%Maker{function: maker}|rest], intermed) do
    [maker.(intermed)|rest]
  end
  defp _close([head|rest], intermed) do
    _close(rest, [head|intermed])
  end

  defp _make_pairs(map) do
    map
    |> Map.to_list
    |> Enum.map(&Pair.new(&1))
  end
  defp _transform(value, transformer) do
    if Traverse.Ignore.me?(value), do: value, else: transformer.(value)
  end
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

    defp mapall_post(%{__struct__: _type}=ds, transformer) do
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

    defp _reduce_to_maker(result, intermed \\ [])
    defp _reduce_to_maker([%Maker{function: fun}|rest], intermed) do
      [fun.(intermed)|rest]
    end
    defp _reduce_to_maker([head|tail], intermed) do
      _reduce_to_maker(tail, [head|intermed])
    end
end
