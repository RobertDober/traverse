defmodule Traverse.Walker do

  use Traverse.Types

  @moduledoc """
  Implements all the different traversal functions exposed by `Traverse`.
  """

  @doc false
  @spec walk( any, any, t_simple_walker_fn ) :: any 
  def walk( coll, acc, collector ) 

  def walk( ele, acc, collector ) when is_tuple(ele) do
    with acc <- ele
      |> Tuple.to_list()
      |> Enum.reduce( acc, &(walk(&1, &2, collector) ) ),
      do: collector.(ele, acc)
  end

  def walk( ele, acc, collector) when is_list(ele) do
    with acc <- ele
      |> Enum.reduce( acc, &(walk(&1, &2, collector) ) ),
      do: collector.(ele, acc)
  end

  def walk( ele, acc, collector ) when is_map(ele) do
    with acc <- ele
      |> Enum.reduce( acc, &(walk(&1, &2, collector) ) ),
      do: collector.(ele, acc)
  end

  def walk( ele, acc, collector ) do
    collector.(ele, acc)
  end

  @doc false
  @spec simple_pre_walk( any, any, t_simple_walker_fn ) :: any 
  def simple_pre_walk( coll, acc, collector ) 

  def simple_pre_walk( ele, acc, collector ) when is_tuple(ele) do
    with acc <- collector.(ele, acc) do
      ele
      |> Tuple.to_list()
      |> Enum.reduce( acc, &(simple_pre_walk(&1, &2, collector) ) )
    end
  end

  def simple_pre_walk( ele, acc, collector) when is_list(ele) do
    with acc <- collector.(ele, acc) do
      ele
      |> Enum.reduce( acc, &(simple_pre_walk(&1, &2, collector) ) )
    end
  end

  def simple_pre_walk( ele, acc, collector ) when is_map(ele) do
    with acc <- collector.(ele, acc) do
      ele
      |> Enum.reduce( acc, &(simple_pre_walk(&1, &2, collector) ) )
    end
  end

  def simple_pre_walk( ele, acc, collector ) do
    collector.(ele, acc)
  end

end
