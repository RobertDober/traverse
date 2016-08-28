defmodule Traverse.WalkWFunTest do
  use ExUnit.Case
  import Traverse, only: [walk: 3]


  defmodule Evaluator do 

    def evaluate([:+|args], acc) do 
      values = evaluate_list(args)
      %Traverse.Cut{acc: [sum(values) | acc]}
    end

    def evaluate([:*|args], acc) do 
      values = evaluate_list(args)
      %Traverse.Cut{acc: [prod(values) | acc]}
    end

    def evaluate({:*, lhs, rhs}, acc) do 
      values = evaluate_list([lhs, rhs])
      %Traverse.Cut{acc: [prod(values) | acc]}
    end

    def evaluate(x, acc), do: [x|acc]

    defp evaluate_list(args) do 
      args
      |> Enum.flat_map(fn arg -> Traverse.walk(arg, [], &evaluate/2) end)
    end

    defp prod(values) do
      values
      |> Enum.reduce(1, fn ele, acc -> ele * acc end)
    end

    defp sum(values) do
      values
      |> Enum.reduce(0, fn ele, acc -> ele + acc end)
    end
  end

end
