defmodule JetFilters.Operator.CO do
  @moduledoc """
  包含（contain）：
  - 用于 `string` 时，表明右边的字符串是左边的子串
  - 用于 `array` 时，表明右边数组的每一元素都是左边数组的元素
  """

  use JetFilters.Operator, [
    [{:array, {:_var, 0}}, {:array, {:_var, 0}}],
    [:string, :string]
  ]

  build_to_dynamic([:string, :string]) do
    dynamic(fragment("? LIKE '%' || ? || '%'", ^op1, ^op2))
  end

  build_to_dynamic([{:array, type}, {:array, type}]) do
    dynamic(fragment("? @> ?", ^op1, ^op2))
  end
end
