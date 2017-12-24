defmodule Traverse.Enum do
  alias Traverse.Error


  @moduledoc """
    ## Traverse.Enum offers some extension functions for Elixir's Enum module
    
    ### Grouped Accumulation

    Groupes accumulated values of an Enum according to a function that
    indicates if two consequent items are of the same kind and if so
    how to accumulate their two values.

    The `grouped_reduce` function returns the groupes in reverse order, as,
    during traversal of lists quite often reversing the result of the 
    classical "take first and push a function of it to the result" pattern
    cancels out.
    
    An optional, `reverse: true` keyword option can be provided to reverse
    the final result for convenience.

        iex> add_same = fn {x, a}, {y, b} ->
        ...>               cond do
        ...>                 x == y -> {:cont, {x, a + b}}
        ...>                  true   -> {:stop, nil} end end
        ...> E.grouped_reduce(
        ...>   [{:a, 1}, {:a, 2}, {:b, 3}, {:b, 4}], add_same)
        [{:b, 7}, {:a, 3}]

    The `grouped_inject` function behaves almost identically to `grouped_reduce`,
    however an initial value is provided


        iex> sub_same = fn {x, a}, {y, b} -> 
        ...>               cond do
        ...>                 x == y -> {:cont, {x, a - b}}
        ...>                 true   -> {:stop, nil}
        ...>               end
        ...>            end
        ...> E.grouped_inject(
        ...> [{:a, 1}, {:b, 2}, {:b, 2}, {:c, 2}, {:c, 1}, {:c, 1}],
        ...>  {:a, 43}, sub_same, reverse: true)
        [a: 42, b: 0, c: 0]
  """


  @doc false
  def grouped_reduce(xs, gacc_fn, options \\ [])
  def grouped_reduce([], _, _), do: []
  def grouped_reduce([x|xs], f, options) do
    if options[:reverse] do
      grouped_acc_impl(xs, x, f, []) |> Enum.reverse()
    else
      grouped_acc_impl(xs, x, f, []) 
    end
  end

  @doc false
  def grouped_inject(xs, initial, gacc_fn, options \\ [])
  def grouped_inject(xs, initial, f, options) do
    if options[:reverse] do
      grouped_acc_impl(xs, initial, f, []) |> Enum.reverse()
    else
      grouped_acc_impl(xs, initial, f, [])
    end
  end

  defp grouped_acc_impl(xs, acc, f, result)
  defp grouped_acc_impl([], acc, _, result), do: [acc|result]
  defp grouped_acc_impl([x|xs], acc, f, result) do
    case f.(acc, x) do
      {:cont, combination} -> grouped_acc_impl(xs, combination, f, result)
      {:stop, _}           -> grouped_acc_impl(xs, x,           f, [acc|result])
      _                    -> raise Error, "function must be of type {:cont, any()} | {:stop, any()}"
    end
  end

end
