defmodule Traverse.Traverser do
  use Traverse.Types 

  @doc """
    ...
  """
  @spec post_traverse( any, any, t_traverse_fn, t_structure_fn ) :: any
  def post_traverse ds, acc, traverse_fn, structure_fn

  def post_traverse( ele, acc, traverse_fn, structure_fn ) when is_tuple(ele) or is_list(ele) or is_map(ele) do
      case structure_fn.(ele) do
        [node | children] -> traverse_fn.(node, children
                               |> Enum.reduce( acc, &(post_traverse(&1, &2, traverse_fn, structure_fn)) )
                             )
        []                -> acc
      end
  end

  def post_traverse( ele, acc, traverse_fn, _structure_fn ) do
    traverse_fn.(ele, acc)
  end

  @doc """
    ...
  """
  @spec pre_traverse( any, any, t_traverse_fn, t_structure_fn ) :: any
  def pre_traverse ds, acc, traverse_fn, structure_fn

  def pre_traverse( ele, acc, traverse_fn, structure_fn ) when is_tuple(ele) or is_list(ele) or is_map(ele) do
      case structure_fn.(ele) do
        [node | children] -> children
                             |> Enum.reduce(  traverse_fn.(node, acc), &(pre_traverse(&1, &2, traverse_fn, structure_fn)) )
        []                -> acc
      end
  end

  def pre_traverse( ele, acc, traverse_fn, _structure_fn ) do
    traverse_fn.(ele, acc)
  end

end
