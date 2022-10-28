defmodule Traverse.Types do
  defmacro __using__(_options \\ []) do
    quote do
      @type container_t :: list() | map() | struct() | tuple()
      @type leave_mapper_t :: ( any() -> any() )
      @type maybe(t) :: t | nil
      @type pair_t :: {any(), any()}
      @type reducer_event_t :: :open_list | :open_map | :open_struct | :open_tuple | :close_list | :close_map | :close_struct | :close_tuple | :scalar
      @type reducer_first_arg_t :: {reducer_event_t(), any()}
      @type reducer_t :: (reducer_first_arg_t(), any() -> any())
      @type reducer_tuple :: {list(), any(), reducer_t(), Keyword.t()}
      @type singleton_t :: {any()}
    end
  end
end
