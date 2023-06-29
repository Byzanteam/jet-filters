defmodule JetFilters.Operator.SW do
  @moduledoc """
  表示左边的字符串以右边的字符串开头（start with）
  """

  use JetFilters.Operator, [:string, :string]

  build_to_dynamic([:string, :string]) do
    dynamic(fragment("? ^@ ?", ^op1, ^op2))
  end
end

defmodule JetFilters.Operator.EW do
  @moduledoc """
  表示左边的字符串以右边的字符串结尾（end with）
  """

  use JetFilters.Operator, [:string, :string]

  build_to_dynamic([:string, :string]) do
    dynamic(fragment("? LIKE '%' || ?", ^op1, ^op2))
  end
end
