defmodule Traverse do
  use Traverse.Types
  use Traverse.Macros

  defmodule Cut do
    @moduledoc """
    A wrapper around the accumulator value of the traversal function, which will
    avoid recursive decent from this node on.
    """
    defstruct acc: "boxed accumulator"
    def me?(%__MODULE__{}), do: true
    def me?(_), do: false
  end

  defmodule Ignore do
    @moduledoc """
      When a transformer function returns this value the transformation of the
      containing data structure will not contain it, in case the containing data structure is
      a map the key is omitted in the transformation.

      iex> Traverse.map([1, 2, %{a: 1}, {1, 2}], fn _ -> Traverse.Ignore end)
      [%{}, {}]
    """
    @doc """
      Lackmus to decide if an argument is to be ignored, or, in other words, is me.
    """
    def me?(__MODULE__), do: true
    def me?(_), do: false
  end

  @moduledoc """
  # Traverse is a toolset to walk arbitrary Elixir Datastructures.

  ## Walking The Whole Structure

  `walk` visits all substructures down to atomic elements.

       iex(0)> ds = [:a, {:b, 1, 2}, [:c, 3, 4, 5]]
       ...(0)> collector =  fn ele, acc when is_atom(ele) or is_number(ele) -> [ele|acc]
       ...(0)>                 _,   acc                    -> acc       end
       ...(0)> Traverse.walk(ds, [], collector)
       [5, 4, 3, :c, 2, 1, :b, :a]

  But substructures are of course visited too:

      iex(1)> ds = [:a, {:b, 1, 2}, [:c, 3, 4, 5]]
      ...(1)> collector = fn ele, acc -> [ele|acc] end
      ...(1)> Traverse.walk(ds, [], collector) |> Enum.reverse
      [[:a, {:b, 1, 2}, [:c, 3, 4, 5]], :a, {:b, 1, 2}, :b, 1, 2, [:c, 3, 4, 5], :c, 3, 4, 5] 

  This example shows that the default visiting strategy is depth first
  and prewalk, in other words, the algorithm is descending the leftmost path, calling the visiting
  function _before_ descending.

  We can however instruct it to use a postwalk strategy as follows

      iex(2)> ds = [:a, [:c, 3]]
      ...(2)> collector = fn ele, acc -> [ele|acc] end
      ...(2)> Traverse.walk(ds, [], collector, postwalk: true)
      [[:a, [:c, 3]], [:c, 3], 3, :c, :a]

       
  For the time being the depth first strategy cannot be changed.
  
  ### Cutting substructures off

  Let us say that we do not want to traverse certain, subtrees, as in the following example
  in which `%TraverseCut{}` is used to cut subtrees if which the key is `:ignore`:

      iex(3)> ds = %{a: %{ignore: [1, 3, 4]}, b: 10, c: %{e: 20, d: [f: 30, ignore: 1000]}}
      ...(3)> collector = fn 
      ...(3)>   ele, acc when is_number ele -> acc + ele
      ...(3)>   {:ignore, _}, acc -> %Traverse.Cut{acc: acc}
      ...(3)>   _  , acc -> acc end
      ...(3)> Traverse.walk(ds, 0, collector)
      60

  In postwalk scenarii this does not make any sense of course

      iex(4)> ds = %{a: [1, 2], ignore: [3, 4]}
      ...(4)> collector = fn 
      ...(4)>   ele, acc when is_number ele -> acc + ele
      ...(4)>   {:ignore, _}, acc -> %Traverse.Cut{acc: acc}
      ...(4)>   _  , acc -> acc end
      ...(4)> Traverse.walk(ds, 0, collector, postwalk: true)
      %Traverse.Cut{acc: 10}

  Therefore postwalk does not even unbox the Cut struct which might lead to errors we used
  this example only to show that when the cut is applied the accumulator has already added
  the values from the substructure.


  ### Partial functions


  The astuce reader might have noticed that most of our collector functions above
  had a default clause like that:

       _, acc -> acc end


  It is tempting to complete partial collector functions this way automatically.

  However this has major downsides:
   - application errors are masked by the rescue clause
   - stack traces are harder to read
   - runtime increases

  That said, especially in iex sessions it might be useful to be able doing this.
  Enter the bang version: `walk!`

      iex(5)> ds = %{a: 1, b: 2}
      ...(5)> Traverse.walk!(ds, 0, fn ele, acc when is_number(ele) -> ele + acc end)
      3

  Just to show the difference with the unbanged version of `walk`:

      iex(6)> ds = %{a: 1, b: 2}
      ...(6)> try do
      ...(6)>   Traverse.walk(ds, 0, fn ele, acc when is_number(ele) -> ele + acc end)
      ...(6)> rescue
      ...(6)>   FunctionClauseError -> :rescued 
      ...(6)> end
      :rescued


  The bang version can also be used with `postwalk: true` of course.

      iex(7)> ds = %{a: 1, b: 2}
      ...(7)> Traverse.walk!(ds, 0, fn ele, acc when is_number(ele) -> ele + acc end, postwalk: true)
      3


  ## Mapping

  While walking implements the most general way to traverse common data structures it does not preserve
  the structure of the walked data structure by itself.

  Mapping will descend the data structure and copy it, but apply the mapper function **only** to leaves.

  Therefore it is sufficient to define the __mapper__ function for the type of leave values only.

  However, while map keys are not leaves, keyword lists are just list of tuples and as such the __keys__ are
  considered leaves too.

      iex(8)> ds = [ a: 1, b: %{ c: [1, 2], d: [e: 100, f: 200] } ]
      ...(8)> mapper = fn x when is_number(x) -> x + 1
      ...(8)>             x when is_atom(x)   -> to_string(x)
      ...(8)>             x                   -> x      end
      ...(8)> Traverse.map(ds, mapper)
      [{"a", 2}, {"b", %{c: [2, 3], d: [{"e", 101}, {"f", 201}]}}]


  ### Partial functions

  As seen above it might again be convenient to automatically replace undefined parts
  of the mapper function with the identity function, and the banged version, `map!` is
  just doing that


      iex(9)> ds = [ a: 1, b: %{ c: [1, 2], d: [e: 100, f: 200] } ]
      ...(9)> Traverse.map!(ds, fn x when is_number(x) -> x + 1 end)
      [ a: 2, b: %{ c: [2, 3], d: [e: 101, f: 201] } ]


  ### Structural Preserving Traversal


  While `walk` is a general way of traversing data structures, and `map` is a convenient way
  of applying changes to leaves only, `mapall` is a compromise between both.

  If `walk` just copies the structure of the data structure into its accumulator, `mapall` does
  this automatically by applying the _mapper_ function to the copied data structure.

  This is done via a trick which might cause some confiusion in debugging, while `mapall` does not
  complete the definition of the __mapper__ function like `walk!` and `map!` it still rescues
  `FunctionClauseError` when applying __mapper__ to __inner__ nodes.

  Therefore

      iex(10)> ds = [ %{a: 1, b: 2}, [3]]
      ...(10)> mapper = fn x when is_number(x) -> x + 1 end
      ...(10)> Traverse.mapall(ds, mapper)
      [%{a: 2, b: 3}, [4]]

  But

      iex(11)> ds = [ %{a: 1, b: 2}, [3]]
      ...(11)> try do
      ...(11)>   Traverse.mapall(ds, &(&1 + 1))
      ...(11)> rescue
      ...(11)>    _ -> :rescued
      ...(11)> end
      :rescued

  And
      iex(12)> ds = [ %{a: 1, b: :hello}, [3]]
      ...(12)> mapper = fn x when is_number(x) -> x + 1 end
      ...(12)> try do
      ...(12)>   Traverse.mapall(ds, mapper)
      ...(12)> rescue
      ...(12)>    _ -> :rescued
      ...(12)> end
      :rescued


  ## Filtering


  Filtering could be implemented by `mapall` and a traversal function that returns either
  an `Ignore` value or the input paramater. Let us demonstrate with the following example

      iex(13)> ds = [ %{a: 1}, [2, 3] ]
      ...(13)> odd_list_elements = fn x when is_number(x) -> if rem(x, 2) == 1, do: x, else: Traverse.Ignore  
      ...(13)>                        x when is_list(x)   -> x
      ...(13)>                        _                   -> Traverse.Ignore end
      ...(13)> Traverse.mapall(ds, odd_list_elements)
      [ [3] ]

  `Traverse` filter removes lots of the boilerplate

      iex(14)> ds = [ %{a: 1}, [2, 3] ]
      ...(14)> odd_list_elements = fn x when is_number(x) -> rem(x,2) == 1
      ...(14)>                        x                   -> is_list(x) end
      ...(14)> Traverse.filter(ds, odd_list_elements)
      [ [3] ]


   As with `map` and `walk` there is the bang version, accepting partial filter functions


       iex(15)> number_arrays = fn x when is_number(x) -> true
       ...(15)>                    l when is_list(l)   -> true end
       ...(15)> Traverse.filter!([:a, {1, 2}, 3, [4, :b]], number_arrays)
       [3, [4]]
  """

  @spec walk(any, any, t_simple_walker_fn, Keyword.t()) :: any
  def walk(ds, initial_acc, walker_fn, options \\ [])

  def walk(ds, initial_acc, walker_fn, postwalk: true),
    do: Traverse.Walker.postwalk(ds, initial_acc, walker_fn)

  def walk(ds, initial_acc, walker_fn, _),
    do: Traverse.Walker.walk(ds, initial_acc, walker_fn)

  def walk!(ds, initial_acc, walker_fn, options \\ [])

  def walk!(ds, initial_acc, walker_fn, postwalk: true),
    do: Traverse.Walker.postwalk!(ds, initial_acc, walker_fn)

  def walk!(ds, initial_acc, walker_fn, _),
    do: Traverse.Walker.walk!(ds, initial_acc, walker_fn)

  @spec filter(any, t_simple_filter_fn) :: any
  def filter(ds, filter_fn),
    do: Traverse.Filter.filter(ds, filter_fn)

  @spec filter!(any, t_simple_filter_fn) :: any
  def filter!(ds, filter_fn),
    do: Traverse.Filter.filter!(ds, filter_fn)

  @spec map(any, t_simple_mapper_fn) :: any
  def map(ds, mapper_fn),
    do: Traverse.Mapper.map(ds, mapper_fn)

  @spec map!(any, t_simple_mapper_fn) :: any
  def map!(ds, mapper_fn),
    do: Traverse.Mapper.map!(ds, mapper_fn)

  @spec mapall(any, t_simple_mapper_fn, Keyword.t()) :: any
  def mapall(ds, mapper_fn, options \\ []),
    do: Traverse.Mapper.mapall(ds, mapper_fn, Keyword.get(options, :post, false))

  # @doc """
  #   `zipfn` augments each node and leaf in the data structure, replacing it with the pair
  #   containing its original value and the result of the function applied to the node.

  #   As very often we will be interested in only some specific values we can, as usually,
  #   define a partial zip function, the `default` value is used to complete the zip
  #   function with a constant function returning this value, the `default` defaults to nil.

  #   iex> Tranverse.zip([1, {:a, 2}, %{b: 3, c: "hello"}],
  #   ...>   fn x when is_number(x) -> x + 1 end)
  #   [{1, 2}, {a: 2]end

  # """
  # @spec zip( any, t_simple_mapper_fn, any ) :: any
  # def zip(ds, zipfn, default \\ nil)
end

# SPDX-License-Identifier: Apache-2.0
