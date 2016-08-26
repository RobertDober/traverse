# Traverse


Allow traverse of Enumerables and Tuples with stateful functions, that is functions that can
return new functions to be used in the subtraversal.

**TODO**: Add link to hex doc (or badge).


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

