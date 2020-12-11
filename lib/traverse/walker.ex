defmodule Traverse.Walker do
  use Traverse.Types

  alias Traverse.Cut
  alias Traverse.Maker
  alias Traverse.Open
  alias Traverse.Pair

  import Traverse.Enum, only: [reduce: 3]

  @moduledoc """
  Implements traversal functions, structure is not maintained unless the traversal functions do so. 
  """

  @spec postwalk(any, any, t_simple_walker_fn) :: any
  def postwalk(coll, acc, collector)

  def postwalk(ele, acc, collector) when is_tuple(ele) do
    acc =
      ele
      |> Tuple.to_list()
      |> Enum.reduce(acc, &postwalk(&1, &2, collector))

    collector.(ele, acc)
  end

  def postwalk(ele, acc, collector) when is_list(ele) or is_map(ele) do
    acc =
      ele
      |> reduce(acc, &postwalk(&1, &2, collector))

    collector.(ele, acc)
  end

  def postwalk(ele, acc, collector) do
    collector.(ele, acc)
  end

  @doc """
  Like `walk!` implements collector augmentation for partial collector functions

     iex(0)>  Traverse.Walker.postwalk!( {1, [2, %{a: 3}, 4], 5}, 0,
     ...(0)>                        fn (n, acc) when is_number(n) -> acc + n end)
     15
  """
  @spec postwalk!(any, any, t_simple_walker_fn) :: any
  def postwalk!(ele, acc, collector), do: postwalk(ele, acc, wrapped(collector))

  @doc """
  `walk` implements a top down recursive pre traversal in an arbitrary Elixir datastructure.


      iex(1)>  Traverse.Walker.walk( {1, [2, %{a: 3}, 4], 5}, 0,
      ...(1)>                        fn (n, acc) when is_number(n) -> acc + n
      ...(1)>                            _, acc                    -> acc end )
      15

  The traversal function can avoid recursive descent by returning its accumulator value boxed in a `%Cut{acc: acc}` struct.
  However, in order to avoid the verbose `%Cut{acc: acc}`, `Traverse.cut(acc)` can be used

      iex(2)>  Traverse.Walker.walk( {1, [2, %{a: 3}, 4], 5}, 0,
      ...(2)>                        fn (mp, acc) when is_map(mp) -> Traverse.cut(acc)
      ...(2)>                           (n, acc) when is_number(n) -> acc + n
      ...(2)>                            _, acc                    -> acc end )
      12 
  """
  @spec walk(any, any, t_simple_walker_fn) :: any
  def walk(coll, acc, collector) do
    _walk([coll], acc, collector, [])
  end

  defp _walkx(ds, acc, collector, stack) do
    IO.inspect({ds, acc, stack}, label: "************************\n")
    _walk(ds, acc, collector, stack)
  end

  defp _walk(coll, acc, collector, stack)

  #  defp _walk(%{__struct__: type}=struct, acc, collector) do
  #    _walk(Map.delete(struct, :__struct__), acc, collector)
  #  end
  defp _walk([%Open{data: []}|rest], acc, collector, stack) do
    [result | stack1] = _close(stack, [])
  require IEx; IEx.pry
    acc1 = collector.(result, acc)
    _walk_unless_cut(rest, acc1, collector, stack1)
  end
  defp _walk([%Open{}=open|rest], acc, collector, stack) do
    {head, open_with_tail} = Open.pop(open)
    _walk([head, open_with_tail|rest], acc, collector, stack)
  end
  defp _walk([%Pair{key: :__struct__}|rest], acc, collector, stack) do
#    IO.inspect(:ignore_struct)
    _walk(rest, acc, collector, stack)
  end
  defp _walk([%Pair{key: key, value: value}|rest], acc, collector, stack) do
#    IO.inspect(:pair)
    _walkx([value, Open.new([])|rest], acc, collector, [Maker.make_pair(key)|stack])
  end

  defp _walk([[h|t]|rest], acc, collector, stack) do
#    IO.inspect(:open_list)
    _walkx([h,Open.new(t)|rest], acc, collector, [h, Maker.make_list|stack])
  end
  defp _walk([tpl|rest], acc, collector, stack) when is_tuple(tpl) do
#    IO.inspect(:tuple)
    case Tuple.to_list(tpl) do
      [] -> _walk_unless_cut(rest, collector.({}, acc), collector, stack)
      [h|t] -> _walkx([h, Open.new(t)|rest], acc, collector, [Maker.make_tuple|stack])
    end
  end
  defp _walk([h|t], acc, collector, stack) when h == %{} do
    case collector.(h, acc) do
      %Cut{acc: acc1} -> _walkx(t, acc1, collector, stack)
      acc2            -> _walkx(t, acc2, collector, stack) 
    end
  end
  defp _walk([%{}=h|t], acc, collector, stack) do
  require IEx; IEx.pry
    case collector.(h, acc) do
      %Cut{acc: acc1} -> _walkx(t, acc1, collector, stack)
      acc2            -> _walkx(_open_map(h, t), acc2, collector, [Maker.make_map(Map.get(h, :__struct__))|stack])
    end
  end
  defp _walk([ele|rest], acc, collector, stack) do
    _walk_unless_cut(rest, collector.(ele, acc), collector, stack)
  end
  defp _walk([], acc, _, []) do
    acc
  end
  defp _walk([], acc, _, stack) do
    raise Traverse.InternalError, "stack should be empty at the end:\nstack: #{inspect stack}\nacc: #{inspect acc}"
  end

  defp _walk_unless_cut(input, acc, collector, stack)
  defp _walk_unless_cut(input, %Cut{acc: acc}, collector, stack) do
    acc
  end
  defp _walk_unless_cut(input, acc, collector, stack) do
    _walkx(input, acc, collector, stack)
  end

  defp _close(result, intermed \\ [])
  defp _close([], _intermed), do: raise(Traverse.InternalError, "_close did not find a maker on the stack")
  defp _close([%Maker{function: maker}|rest], intermed) do
    [maker.(intermed)|rest]
  end

  defp _close([head|rest], intermed) do
    _close(rest, [head|intermed])
  end
  defp _open_map(amap, rest) do
    case Pair.make_pairs(amap) do
      [h|t] -> [h, Open.new(t)|rest]
    end
  end

  @doc """
  `walk!` implements a top down recursive pre traversal in an arbitrary Elixir datastructure.
  In contrast to `walk` it augments partial collcetor functions with the second arg of two identity

        _, acc -> acc


      iex(3)>  Traverse.Walker.walk!( {1, [2, %{a: 3}, 4], 5}, 0,
      ...(3)>                        fn (n, acc) when is_number(n) -> acc + n end)
      15

  """
  @spec walk!(any, any, t_simple_walker_fn) :: any
  def walk!(coll, acc, collector), do: walk(coll, acc, wrapped(collector))

  defp wrapped(fun) do
    fn ele, acc ->
      try do
        fun.(ele, acc)
      rescue
        FunctionClauseError -> acc
      end
    end
  end
end
