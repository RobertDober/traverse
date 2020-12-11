defmodule Support.Functions do
  def adder() do
    fn n, m when is_number(n) -> n + m
       _, m                   -> m
    end
  end
  def collect_list_sizes do
    fn n, m when is_list(n) -> m + Enum.count(m)
       _, m                 -> m
    end
  end
end
# SPDX-License-Identifier: Apache-2.0
