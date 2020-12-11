defmodule Traverse.Maker do
  alias Traverse.Pair

  defstruct function: nil 

  def make_list, do: new(&(&1)) 

  def make_map(maybe_struct)
  def make_map(nil) do
    new(fn values ->
      values
      |> Enum.map(&Pair.to_tuple/1)
      |> Enum.into(%{})
    end)
  end
  def make_map(a_struct) do
    new(fn values ->
      struct(a_struct,
      values
      |> Enum.map(&Pair.to_tuple/1)
      |> Enum.into(%{}))
    end)
  end

  def make_pair(for_key) do
    new( fn values -> 
    Pair.new(for_key, List.first(values))
    end)
  end
  def make_tuple, do: new(&List.to_tuple/1)


  defp new(fun), do: %__MODULE__{function: fun}
end
