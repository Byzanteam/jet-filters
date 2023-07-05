defmodule JetFilters.Operator.OV do
  @moduledoc """
  有重叠（overlap），表示两个数组拥有共有的元素
  """

  use JetFilters.Operator, [{:array, {:_var, 0}}, {:array, {:_var, 0}}]

  build_to_dynamic([{:array, type}, {:array, type}]) do
    dynamic(fragment("? && ?", ^op1, ^op2))
  end
end
