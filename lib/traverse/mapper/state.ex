defmodule Traverse.Wrapper.State do
  defstruct result: [], fun: nil

  @type t :: %__MODULE__{result: list(), fun: (any() -> any()) | nil}
end

#  SPDX-License-Identifier: Apache-2.0
