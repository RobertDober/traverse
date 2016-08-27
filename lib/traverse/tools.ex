defmodule Traverse.Tools do

  @doc """
  DEPRECATED
  A convenience method to pass the accumulator through a substructure.
  As soon as cutting substructures is available, this will go away.
  """
  def acc_for_pre do 
    fn _fst, snd -> {snd} end
  end
  
end
