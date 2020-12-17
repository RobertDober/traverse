defmodule Support.Collector do
  @behaviour Traverse.VisitorBehavior 

  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def messages do
     Agent.get(__MODULE__, &Enum.reverse(&1))
  end

  def push(value) do
    Agent.update(__MODULE__, fn list -> [value|list] end)
  end

  # Implementation
  @spec scalar(any()) :: :ok
  def scalar(value) do
    push(value)
    :ok
  end

  @spec open_map() :: :ok
  def open_map() do
    push(:open_map)
    :ok
  end

  @spec close_map() :: :ok
  def close_map() do
    push(:close_map)
    :ok
  end

  @spec open_list() :: :ok
  def open_list() do
    push(:open_list)
    :ok
  end

  @spec close_list() :: :ok
  def close_list() do
    push(:close_list)
    :ok
  end

  @spec open_struct(module()) :: :ok
  def open_struct(module) do
    push({:open_struct, module})
    :ok
  end

  @spec close_struct(module()) :: :ok
  def close_struct(module) do
    push({:close_struct, module})
    :ok
  end

  @spec open_tuple() :: :ok
  def open_tuple() do
    push(:open_tuple)
    :ok
  end

  @spec close_tuple() :: :ok
  def close_tuple() do
    push(:close_tuple)
    :ok
  end
end
