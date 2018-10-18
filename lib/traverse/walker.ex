defmodule Traverse.Walker do
  use Traverse.Types
  alias Traverse.Cut

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
      |> Enum.reduce(acc, &postwalk(&1, &2, collector))
     collector.(ele, acc)
  end

  def postwalk(ele, acc, collector) do
    collector.(ele, acc)
  end

  @doc """
  Like `walk!` implements collector augmentation for partial collector functions

     iex(1)>  Traverse.Walker.postwalk!( {1, [2, %{a: 3}, 4], 5}, 0,
     ...(1)>                        fn (n, acc) when is_number(n) -> acc + n end)
     15
  """
  @spec postwalk!(any, any, t_simple_walker_fn) :: any 
  def postwalk!(ele, acc, collector), do:
    postwalk(ele, acc, wrapped(collector))

  @doc """
  `walk` implements a top down recursive pre traversal in an arbitrary Elixir datastructure.


      iex(2)>  Traverse.Walker.walk( {1, [2, %{a: 3}, 4], 5}, 0,
      ...(2)>                        fn (n, acc) when is_number(n) -> acc + n
      ...(2)>                            _, acc                    -> acc end )
      15

  The traversal function can avoid recursive descent by returning its accumulator value boxed in a `%Cut{acc: acc}` struct.
  """
  @spec walk(any, any, t_simple_walker_fn) :: any
  def walk(coll, acc, collector)

  def walk(ele, acc, collector) when is_map(ele) or is_list(ele) do
    case collector.(ele, acc) do
      %Cut{acc: acc} ->
        acc

      acc ->
        ele
        |> Enum.reduce(acc, &walk(&1, &2, collector))
    end
  end

  def walk(ele, acc, collector) when is_tuple(ele) do
    case collector.(ele, acc) do
      %Cut{acc: acc} ->
        acc

      acc ->
        ele
        |> Tuple.to_list()
        |> Enum.reduce(acc, &walk(&1, &2, collector))
    end
  end

  def walk(ele, acc, collector) do
    collector.(ele, acc)
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
  def walk!(coll, acc, collector), do:
    walk(coll, acc, wrapped(collector))

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
