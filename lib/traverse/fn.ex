defmodule Traverse.Fn do
  use Traverse.Types

  @doc """
    Allows to complete a partial function

        iex> partial = fn x when is_number(x) -> x + 1 end
        ...> complete =  Traverse.Fn.complete_function(partial, Traverse.Fn.identity)
        ...> Enum.map([1, :a, []], complete)
        [2, :a, []]

    As this is a common case there is a helper that does that for us:

        iex> partial = fn x when is_number(x) -> x + 1 end
        ...> complete =  Traverse.Fn.complete_with_identity(partial)
        ...> Enum.map([1, :a, []], complete)
        [2, :a, []]
          
  """
  @spec complete_function((any -> any), (any -> any)) :: (any -> any)
  def complete_function(partial_fn, with_fn) do
    fn arg ->
      try do
        partial_fn.(arg)
      rescue
        FunctionClauseError -> with_fn.(arg)
      end
    end
  end

  @doc """
    A convenience declaration of the identity function.
  """
  @spec identity(any) :: any
  def identity(any), do: any

end
