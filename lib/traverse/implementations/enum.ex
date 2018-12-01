defmodule Traverse.Implementations.Enum do
  defmacro __using__(_options) do
    quote do
      defimpl Enumerable do
        def count(_), do: {:error, __MODULE__}

        def member?(stru, ele), do: stru |> Map.from_struct() |> Enumerable.member?(ele)

        def reduce(_, {:halt, acc}, _fun), do: {:halted, acc}
        def reduce(stru, {:suspend, acc}, fun), do: {:suspended, acc, &reduce(stru, &1, fun)}

        def reduce(stru, {:cont, acc}, fun) do
          stru |> Map.from_struct() |> Enumerable.reduce({:cont, acc}, fun)
        end

        def slice(_), do: {:error, __MODULE__}
      end
    end
  end
end
