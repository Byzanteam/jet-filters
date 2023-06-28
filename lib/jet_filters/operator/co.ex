defmodule JetFilters.Operator.CO do
  @moduledoc false

  use JetFilters.Operator, [
    [{:array, {:_var, 0}}, {:array, {:_var, 0}}],
    [:string, :string]
  ]

  build_to_dynamic([:string, :string]) do
    dynamic(fragment("? LIKE '%' || ? || '%'", ^op1, ^op2))
  end

  build_to_dynamic([{:array, _type1}, {:array, _type2}]) do
    dynamic(fragment("? @> ?", ^op1, ^op2))
  end
end
