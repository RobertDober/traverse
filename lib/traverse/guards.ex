defmodule Traverse.Guards do
  
  defmacro is_scalar(x) do
    quote bind_quoted: [x: x] do
      not is_list(x) and not is_map(x) and not is_tuple(x)
    end
  end
end
