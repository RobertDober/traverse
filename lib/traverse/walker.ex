defmodule Traverse.Walker do

  use Traverse.Types
  alias Traverse.Cut
  alias Traverse.Fun

  @moduledoc """
  Implements all the different traversal functions exposed by `Traverse`.
  """

  @doc false

  @doc false
  @spec walk( any, any, t_simple_walker_fn ) :: any 
  def walk( coll, acc, collector ) 

  def walk( ele, acc, collector ) when is_tuple(ele) do
    case collector.(ele, acc) do
      %Cut{acc: acc} -> acc
      %Fun{acc: acc, fun: fun} -> ele
                        |> Tuple.to_list()
                        |> Enum.reduce( acc, &(walk(&1, &2, fun) ) )
      acc            -> ele
                        |> Tuple.to_list()
                        |> Enum.reduce( acc, &(walk(&1, &2, collector) ) )
    end
  end

  def walk( ele, acc, collector) when is_list(ele) do
    case collector.(ele, acc) do
      %Cut{acc: acc} -> acc
      %Fun{acc: acc, fun: fun} -> ele
                        |> Enum.reduce( acc, &(walk(&1, &2, fun) ) )
      acc            -> ele
                        |> Enum.reduce( acc, &(walk(&1, &2, collector) ) )
    end
  end

  def walk( ele, acc, collector ) when is_map(ele) do
    with acc <- collector.(ele, acc) do
      ele
      |> Enum.reduce( acc, &(walk(&1, &2, collector) ) )
    end
  end

  def walk( ele, acc, collector ) do
    collector.(ele, acc)
  end

end
