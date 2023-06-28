defmodule JetFilters.Operator.Ov do
  @moduledoc false

  use JetFilters.Operator, [{:array, {:_var, 0}}, {:array, {:_var, 0}}]

  build_to_dynamic([{:array, _type1}, {:array, _type2}]) do
    dynamic(fragment("? && ?", ^op1, ^op2))
  end
end
