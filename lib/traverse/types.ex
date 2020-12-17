defmodule Traverse.Types do
  defmacro __using__(_options \\ []) do
    quote do
      @type leave_mapper_t :: ( any() -> any() )
      @type maybe(t) :: t | nil
      @type reducer_event_t :: :open_list | :open_map | :open_struct | :open_tuple | :close_list | :close_map | :close_struct | :close_tuple | :scalar
      @type reducer_first_arg_t :: {reducer_event_t(), any()}
      @type reducer_t :: (reducer_first_arg_t(), any() -> any())
      @type reducer_triple :: {list(), any(), reducer_t()}
    end
  end
end
