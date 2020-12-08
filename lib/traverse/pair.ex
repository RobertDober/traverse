defmodule Traverse.Pair do
  defstruct key: nil, value: nil


  def new({key, value}) do
    %__MODULE__{key: key, value: value}
  end

  def new(key, value) do
    %__MODULE__{key: key, value: value}
  end

  def to_tuple(%__MODULE__{key: key, value: value}) do
    {key, value}
  end
end

