defmodule JetFilters.Operator.PR do
  @moduledoc """
  有值（present）：
  - 用于 `string` 时，表示字符串不是空串（`""`）
  - 用于 `array` 时，表示数组非空（一个只包含 0 ～ N 个 NULL 的数组是空数组）
  """

  use JetFilters.Operator, [
    [{:array, {:_var, 0}}],
    [:string]
  ]

  build_to_dynamic([:string]) do
    dynamic(not (is_nil(^op) or ^op == ""))
  end

  build_to_dynamic([_array]) do
    dynamic(not is_nil(^op) and fragment("array_remove(?, NULL) = '{}'", ^op))
  end
end
