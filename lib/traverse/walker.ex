defmodule Traverse.Walker do

  use Traverse.Types
  alias Traverse.Cut

  @moduledoc """
  Implements all the different traversal functions exposed by `Traverse`.
  """

  @doc """
    `walk` implements a top down recursive pre traversal in an arbitrary Elixir datastructure.

    Lists and Tuples are traversed, while maps are considered scalar data.

        iex>  Traverse.Walker.walk( {1, [2, %{a: 3}, 4], 5}, 0,
        ...>                        fn (n, acc) when is_number(n) -> acc + n
        ...>                            _, acc                    -> acc end )
        12

    The traversal function can avoid recursive descent by returning its accumulator value boxed in a `%Cut{acc: acc}` struct.
  """
  @spec walk( any, any, t_simple_walker_fn ) :: any 
  def walk( coll, acc, collector ) 

  def walk( ele, acc, collector ) when is_tuple(ele) do
    case collector.(ele, acc) do
      %Cut{acc: acc} -> acc
      acc            -> ele
                        |> Tuple.to_list()
                        |> Enum.reduce( acc, &(walk(&1, &2, collector) ) )
    end
  end

  def walk( ele, acc, collector) when is_list(ele) do
    case collector.(ele, acc) do
      %Cut{acc: acc} -> acc
      acc            -> ele
                        |> Enum.reduce( acc, &(walk(&1, &2, collector) ) )
    end
  end

  def walk( ele, acc, collector ) do
    collector.(ele, acc)
  end

end
