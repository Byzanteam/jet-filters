defmodule JetFilters.Operator.EQ do
  @moduledoc false

  use JetFilters.Operator, [{:_var, 0}, {:_var, 0}]

  build_to_dynamic([type, type]) do
    dynamic(^op1 == ^op2)
  end
end
