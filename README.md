# Traverse

[![Build Status](https://travis-ci.org/RobertDober/traverse.svg?branch=master)](https://travis-ci.org/RobertDober/traverse)
[![Hex.pm](https://img.shields.io/hexpm/v/traverse.svg)](https://hex.pm/packages/traverse)
[![Coverage Status](https://coveralls.io/repos/RobertDober/traverse/badge.png)](https://coveralls.io/r/RobertDober/traverse)
[![Inline docs](http://inch-ci.org/github/RobertDober/traverse.svg?branch=master)](http://inch-ci.org/github/RobertDober/traverse)

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

