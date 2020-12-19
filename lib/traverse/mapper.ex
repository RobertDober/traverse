defmodule Traverse.Mapper do
  use Traverse.Types
  alias Traverse.Wrapper

  @moduledoc false

  @spec flat_mapper(leave_mapper_t()) :: reducer_t()
  def flat_mapper(mapper) do
    fn  {:open_list, _}, acc -> [Wrapper.List.new | acc]
        {:open_tuple, _}, acc -> [Wrapper.Tupple.new | acc]
        {:scalar ,value}, [wrapper|rest] -> [wrapper.__struct__.push(wrapper, mapper.(value))|rest]
      _ , _ -> raise "continue here"
    end
  end

  @spec leave_mapper(leave_mapper_t()) :: reducer_t()
  def leave_mapper(mapper) do
    fn {:scalar, value}, acc -> _add_mapped(value, acc, mapper)
       _anything, acc        -> acc
    end
  end

  @spec _add_mapped(container_t(), any(), leave_mapper_t()) :: any() 
  defp _add_mapped(value, acc, mapper) do
    mapped = mapper.(value)
    case acc do
      l when is_list(l) -> [ mapped | l]

    end
  end
end
