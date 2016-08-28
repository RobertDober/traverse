# Traverse
<!-- moduledoc: Traverse -->
## Traverse is a toolset to walk arbitrary Elixir Datastructures.

`walk` visits all substructures down to atomic elements.

    iex>    ds = [:a, {:b, 1, 2}, [:c, 3, 4, 5]]
    ...>    collector =  fn ele, acc when is_atom(ele) or is_number(ele) -> [ele|acc]
    ...>                    _,   acc                    -> acc       end
    ...>    Traverse.walk(ds, [], collector)
    [5, 4, 3, :c, 2, 1, :b, :a]

 One can return the accumulator boxed in a `%Cut{}` struct to avoid traversal of the
 subtree.

    iex>   ds = [add: [1, 2], ignore: [3, 4]]
    ...>   collector = fn {:ignore, _}, acc        -> %Traverse.Cut{acc: acc}
    ...>                  n, acc when is_number(n) -> [n|acc]
    ...>                  _, acc                   -> acc end
    ...>   Traverse.walk(ds, [], collector)
    [2, 1]

Instead of ignoring, we could have changed the traverse function for the subtree, which
would have been more inefficent but demonstrates a different technique:

    iex>   ds = [add: [1, 2], ignore: [3, 4]]
    ...>   pass_acc = fn _, acc -> acc end
    ...>   collector = fn {:ignore, _}, acc        -> %Traverse.Fun{acc: acc, fun: pass_acc}
    ...>                  n, acc when is_number(n) -> [n|acc]
    ...>                  _, acc                   -> acc end
    ...>   Traverse.walk(ds, [], collector)
    [2, 1]
<!-- endmoduledoc: Traverse -->

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `traverse` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:traverse, "~> 0.1.0"}]
    end
    ```

  2. Ensure `traverse` is started before your application:

    ```elixir
    def application do
      [applications: [:traverse]]
    end
    ```

