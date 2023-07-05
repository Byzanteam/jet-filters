defmodule JetFilters.Operator.IsNull do
  @moduledoc false

  use JetFilters.Operator, [{:_var, 0}]

  build_to_dynamic([_type]) do
    dynamic(is_nil(^op))
  end
end
