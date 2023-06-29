defmodule JetFilters.Operator.PR do
  @moduledoc false

  use JetFilters.Operator, [
    [{:array, {:_var, 0}}],
    [:string]
  ]

  build_to_dynamic([{:array, _type}]) do
    dynamic(not is_nil(^op) and fragment("array_remove(?, NULL) = '{}'", ^op))
  end

  build_to_dynamic([:string]) do
    dynamic(not (is_nil(^op) or ^op == ""))
  end
end
