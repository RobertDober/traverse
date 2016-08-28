defmodule Traverse.Traverser do
  use Traverse.Types 

  @doc """
    ...
  """
  @spec post_traverse( any, any, t_traverse_fn, t_structure_fn ) :: any
  def post_traverse ds, acc, traverse_fn, structure_fn

  def post_traverse( [], acc, _traverse_fn, _structure_fn ), do: acc
  def post_traverse( [node|children], acc, traverse_fn, structure_fn ) do
    traverse_fn.(node, children
                       |> Enum.reduce( acc, &(post_traverse(&1, &2, traverse_fn, structure_fn)) )
               )
  end

  def post_traverse( ele, acc, traverse_fn, structure_fn ) do
    case structure_fn.(ele) do
      lst = [_h|_r] -> post_traverse(lst, acc, traverse_fn, structure_fn)
      _             -> traverse_fn.(ele, acc)
    end
  end

  @doc """
    ...
  """
  @spec pre_leaves( any, any, t_traverse_fn, t_structure_fn ) :: any
  def pre_leaves ds, acc, traverse_fn, structure_fn

  def pre_leaves( [], acc, _traverse_fn, _structure_fn), do: acc
  def pre_leaves( [node|children], acc, traverse_fn, structure_fn ) do
     children
     |> Enum.reduce(acc, &(pre_leaves(&1, &2, traverse_fn, structure_fn)) )
  end

  def pre_leaves( ele, acc, traverse_fn, structure_fn ) do
    case structure_fn.(ele) do
      []            -> acc
      lst = [_h|_r] -> pre_leaves(lst, acc, traverse_fn, structure_fn)
      _             -> traverse_fn.(ele, acc)
    end

  end

  @doc """
    ...
  """
  @spec pre_traverse( any, any, t_traverse_fn, t_structure_fn ) :: any
  def pre_traverse ds, acc, traverse_fn, structure_fn

  def pre_traverse( [], acc, _traverse_fn, _structure_fn), do: acc
  def pre_traverse( [node | children], acc, traverse_fn, structure_fn ) do
    children
    |> Enum.reduce(  traverse_fn.(node, acc), &(pre_traverse(&1, &2, traverse_fn, structure_fn)) )
  end

  def pre_traverse( ele, acc, traverse_fn, structure_fn ) do
    case structure_fn.(ele) do
      []            -> acc
      lst = [_h|_r] -> pre_traverse(lst, acc, traverse_fn, structure_fn)
      _             -> traverse_fn.(ele, acc)
    end
  end

end
