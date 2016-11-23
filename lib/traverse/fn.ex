defmodule Traverse.Fn do
  use Traverse.Types

  @moduledoc """
    Implements convenience functions, and function wrappers to complete
    partial functions.

    The latter is done by catching `FunctionClauseError`. 

        iex> partial = fn x when is_atom(x) -> to_string(x) end
        ...> complete = Traverse.Fn.complete(partial, fn x -> x + 1 end)
        ...> Enum.map([1, :a], complete)
        [2, "a"]
    
  """

  @doc """
    Allows to complete a partial function

        iex> partial = fn x when is_number(x) -> x + 1 end
        ...> complete =  Traverse.Fn.complete(partial, Traverse.Fn.identity)
        ...> Enum.map([1, :a, []], complete)
        [2, :a, []]

    There are common cases like this, and here are some convenience functions for them

    * `complete_with_identity`

        iex> partial = fn x when is_number(x) -> x + 1 end
        ...> complete =  Traverse.Fn.complete_with_identity(partial)
        ...> Enum.map([1, :a, []], complete)
        [2, :a, []]


    * `complete_with_const`

        iex> partial = fn x when is_number(x) -> x + 1 end
        ...> complete =  Traverse.Fn.complete_with_const(partial, 32)
        ...> Enum.map([1, :a, []], complete)
        [2, 32, 32]

    Or with the default    
    
        iex> partial = fn x when is_number(x) -> x + 1 end
        ...> complete =  Traverse.Fn.complete_with_const(partial)
        ...> Enum.map([1, :a, []], complete)
        [2, nil, nil]

    * `complete_with_ignore`
    
        iex> partial = fn x when is_number(x) -> x + 1 end
        ...> complete =  Traverse.Fn.complete_with_ignore(partial)
        ...> Enum.map([1, :a, []], complete)
        [2, Traverse.Ignore, Traverse.Ignore]
          
  """
  @spec complete((any -> any), (any -> any)) :: (any -> any)
  def complete(partial_fn, with_fn) do
    fn arg ->
      try do
        partial_fn.(arg)
      rescue
        FunctionClauseError -> with_fn.(arg)
      end
    end
  end

  @doc """
    Convenience function as described in doc of `complete`.
  """
  @spec complete_with_const((any -> any), any) :: (any -> any)
  def complete_with_const(partial_fn, const \\ nil) do
    complete(partial_fn, fn _ -> const end)
  end

  @doc """
    Convenience function as described in doc of `complete`.
  """
  @spec complete_with_identity((any -> any)) :: (any -> any)
  def complete_with_identity(partial_fn), do: complete(partial_fn, identity)

  @doc """
    Convenience function as described in doc of `complete`.
  """
  @spec complete_with_ignore((any -> any)) :: (any -> any)
  def complete_with_ignore(partial_fn), do: complete_with_const(partial_fn, Traverse.Ignore)

  @doc """
    A convenience declaration of the identity function.

        iex> Traverse.Fn.identity.(42)
        42
  """
  @spec identity :: (any -> any)
  def identity do
    fn any -> any end
  end

end
