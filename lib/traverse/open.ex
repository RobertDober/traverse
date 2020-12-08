defmodule Traverse.Open do
  defstruct data: nil

  def new(data), do: %__MODULE__{data: data}

  def pop(open)
  def pop(%__MODULE__{data: [h|t]}) do
    {h, new(t)}
  end
  def pop(_) do
    raise(Traverse.InternalError, "must not pop from empty #{__MODULE__}")
  end
end

