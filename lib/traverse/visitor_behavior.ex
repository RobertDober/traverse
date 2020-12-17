defmodule Traverse.VisitorBehavior do
  
  # Notification that we visit anything but a List, Map, Tuple or struct
  @callback scalar(any()) :: :ok

  @callback open_map() :: :ok
  @callback close_map() :: :ok
  @callback open_list() :: :ok
  @callback close_list() :: :ok
  @callback open_struct(module) :: :ok
  @callback close_struct(module) :: :ok
  @callback open_tuple() :: :ok
  @callback close_tuple() :: :ok
end

