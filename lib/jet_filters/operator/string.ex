defmodule JetFilters.Operator.Sw do
  @moduledoc false

  use JetFilters.Operator, [:string, :string]

  build_to_dynamic([:string, :string]) do
    dynamic(fragment("? ^@ ?", ^op1, ^op2))
  end
end

defmodule JetFilters.Operator.Ew do
  @moduledoc false

  use JetFilters.Operator, [:string, :string]

  build_to_dynamic([:string, :string]) do
    dynamic(fragment("? LIKE '%' || ?", ^op1, ^op2))
  end
end
