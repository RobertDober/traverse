defmodule Traverse do
  use Traverse.Types

  alias Traverse.Wrapper


  @moduledoc """
  # Traverse... arbitrary Elixir Datastructures.

  ## Synopsis

  `Traverse` exposes functions to, surprise, surprise, traverse arbitrary Elixir datastructures.

  And with arbitrary datastructures we mean any combination of lists, maps, tuples and structs. 

  ## Overview

  ### Visitor and Reducer Pattern

  Firstly there is `visit`, which implements the classic visitor pattern. It accepts a `visitor`,
  which needs to implement `Traverse.VisitorBehavior` (this is not a typo but _en-us_ is my choice of language
  and when _en-en_ is used it is by pure ignorance and YHS would be happy to be adverted of it)
  Then `visit` traverses a given datastructure and invokes the function corresponding to each event.

  E.g. given the following datastructure

  ```elixir
  visit([ {:a, %{k: 1}, :b} ], visitor)
  ```

  the following function invocations on `visitor` would happen

  ```elixir
  open_list, open_tuple, scalar(:a), open_map, open_tuple, scalar(:k), scalar(1), close_tuple, close_map, scalar(:b), close_tuple, close_list
  ```

  Secondly there is `reduce` which implements a functional traversal. It accepts an intital accumulator and a reducer function which will be called
  with an event, value tuple and the accumulator like so:

  ```elixir
  reduce([ {:a, %{k: 1}, :b} ], acc, reducer)
  ```

  Will call reducer with the following values:

  ```elixir
  reducer {:open_list, nil}, acc -> acc1
  reducer {:open_tuple, nil}, acc1 -> acc2
  reducer {:scalar, :a}, acc2      -> acc3
  reducer {:open_map, nil}, acc3   -> acc4
  reducer {:open_tuple, ...
  reducer {:scalar, :k},...
  reducer {:scalar, 1}, ...
  reducer {:close_tuple, nil}, ...
  ...
  ```

  These two _main_ functions are of course enough to implement any imaginable transformation of an arbitrary datastructure, however many
  routinely useful transformations like mapping, flatmapping or filtering would need a lot of boiler plate code to be implemented in the
  reducer or visitor all the time.

  For this reason `Traverse` has done the work behind the scenes to expose these common patterns to simple _mapper_ or _filter_ functions

  ### Mapper Interface

  We distinguish between three different types of mappers.

  - Flat -> `flat_map`
  - Structure Preserving Leaves Mapping (meaning scalar events) -> `map_leaves`
  - Full Mapping on All Nodes -> `map_all`

  While the `flat_map` function is actually trivial to implement with `reduce` its implementation is quite instructive

  ```elixir
  def flat_map(ds, mapper) do
  reduce(ds, [], fn {:scalar, value}, acc -> [mapper.(value)|acc],
  _,                acc -> acc end)
  |> Enum.reverse
  end
  ```

  `map_leaves` of course has to recreate the structure and cannot be sketched out like that, but here is what it does:

  ```elixir
    iex(0)> map_leaves([{1, %{b: 2}, 3}],
    ...(0)>   fn n when is_number(n) -> n + 1,
    ...(0)>      x -> x end # needed as map keys are passed in 
    [{2, %{b: 3}, 4}]
  ```

  There is a convenience version of `map_leaves` that is slower and might hide subtle errors as it wraps your mapper into
  a function that catches `FunctionClauseError` exceptions and mimics the identity function.
  Often, though, it is good enough

  ```elixir
    iex(1)> map_leaves!([{1, %{b: 2}, 3}], fn n when is_number(n) -> n + 1 end)
    [{2, %{b: 3}, 4}]
  ```

  However this contrived example is just a bad use case, as e.g. it would not catch non numeric scalar values that are,
  allegedly not expected, that is why actually the option `ignore_keys: true` should have been passed in:

  ```elixir
    iex(2)> map_leaves([{1, %{b: 2}, 3}], &(&1+1), ignore_keys: true)
    [{2, %{b: 3}, 4}]
  ```

  This option concerns maps **and** structs.
  """

  @doc """
  map_leaves a structural perserving transformation of leave nodes
  """
  @spec map_leaves(any(), leave_mapper_t(), Keyword.t()) :: any()
  def map_leaves(ds, mapper, opts \\ []) do
    ds
  end

  @doc """
  map_leaves! like map but ignores `FunctionClauseError` exceptions
  """
  @spec map_leaves!(any(), leave_mapper_t(), Keyword.t()) :: any()
  def map_leaves!(ds, mapper, opts \\ []) do
    map_leaves(ds, _wrap(mapper), opts)
  end

  @doc """
  reduce functional traversal
  """
  @spec reduce(any(), any(), reducer_t()) :: any()
  def reduce(ds, accumulator, reducer), do: _reduce({[ds], accumulator, reducer})

  @doc """
  visit event based traversal
  """
  @spec visit(any(), any()) :: :ok
  def visit(ds, visitor), do: _visit({[ds], visitor})

  @spec _reduce(reducer_triple()) :: any()
  defp _reduce(stack_accumulator_reducer)
  defp _reduce({[h|t]=stack, accumulator, reducer}) when is_struct(h) do
    case h do
      %Wrapper.List{}   -> _red(h, stack, accumulator, reducer)
      %Wrapper.Map{}    -> _red(h, stack, accumulator, reducer)
      %Wrapper.Struct{} -> _red(h, stack, accumulator, reducer)
      %Wrapper.Tuple{}  -> _red(h, stack, accumulator, reducer)
      _      -> _reduce({[Wrapper.Struct.new(h) | t], accumulator, reducer})
    end
  end
  defp _reduce({[h|t], accumulator, reducer}) when is_list(h) do
    _reduce({[Wrapper.List.new(h)|t], accumulator, reducer})
  end
  defp _reduce({[h|t], accumulator, reducer}) when is_map(h) do
    _reduce({[Wrapper.Map.new(h)|t], accumulator, reducer})
  end
  defp _reduce({[h|t], accumulator, reducer}) when is_tuple(h) do
    _reduce({[Wrapper.Tuple.new(h)|t], accumulator, reducer})
  end
  defp _reduce({[h|t], accumulator, reducer}) do
    _reduce({t, reducer.(h, accumulator), reducer})
  end
  defp _reduce({[], accumulator, _reducer}) do
    accumulator
  end

  defp _reduce_with_open_struct(a_struct, tail, accumulator, reducer) do
    acc1 = reducer.({:open_struct, a_struct}, accumulator)
    _reduce({tail, acc1, reducer})
  end
  # @spec _visitx({list(), any()}) :: :ok
  # defp _visitx({ds, _}=pair) do
    #   IO.puts "================================================================================"
    #   IO.inspect(ds)
    #   _visit(pair)
    # end
    @spec _visit({list(), module()}) :: :ok
    defp _visit(stack_visitor_pair)
    defp _visit({[h|t]=stack, visitor}) when is_struct(h) do
      case h do
        %Wrapper.List{}   -> _pop(h, stack, visitor)
        %Wrapper.Map{}    -> _pop(h, stack, visitor)
        %Wrapper.Struct{} -> _pop(h, stack, visitor)
        %Wrapper.Tuple{}  -> _pop(h, stack, visitor)
        _      -> _visit(_make_struct(h, t, visitor))
      end
    end
    defp _visit({[h|t], visitor}) when is_list(h) do
      visitor.open_list
      _visit({[Wrapper.List.new(h)|t], visitor})
    end
    defp _visit({[h|t], visitor}) when is_map(h) do
      visitor.open_map
      _visit({[Wrapper.Map.new(h)|t], visitor})
    end
    defp _visit({[h|t], visitor}) when is_tuple(h) do
      visitor.open_tuple
      _visit({[Wrapper.Tuple.new(h)|t], visitor})
    end
    defp _visit({[h|t], visitor}) do
      visitor.scalar(h)
      _visit({t, visitor})
    end
    defp _visit({[], _visitor}), do: :ok

    @spec _make_struct(map(), list(), module()) :: {list(), module()}
    defp _make_struct(a_struct, tail, visitor) do
      struct = Wrapper.Struct.new(a_struct)
      visitor.open_struct(struct.struct)
      {[struct | tail], visitor}
    end

    @spec _pop(map(), list(), module()) :: :ok
    defp _pop(a_struct, stack, visitor) do
      _visit(a_struct.__struct__.pop(stack, visitor))
    end

    @spec _red(Wrapper.t(), nonempty_maybe_improper_list(), list(), reducer_t()) :: :ok
    defp _red(a_struct, stack, accumulator, reducer) do
      _reduce(a_struct.__struct__.red(stack, accumulator, reducer))
    end

    @spec _wrap(leave_mapper_t()) :: leave_mapper_t()
    defp _wrap(fun) do
      fn x -> 
      try do
        fun.(x)
      rescue
        FunctionClauseError -> x
      end
      end
    end
end
