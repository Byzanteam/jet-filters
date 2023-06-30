defmodule JetFilters.Operator.GT do
  @moduledoc false

  use JetFilters.Operator, [
    [:string, :string],
    [:number, :number],
    [:datetime, :datetime]
  ]

  build_to_dynamic([type, type]) do
    dynamic(^op1 > ^op2)
  end
end

defmodule JetFilters.Operator.GTE do
  @moduledoc false

  use JetFilters.Operator, [
    [:string, :string],
    [:number, :number],
    [:datetime, :datetime]
  ]

  build_to_dynamic([type, type]) do
    dynamic(^op1 >= ^op2)
  end
end

defmodule JetFilters.Operator.LT do
  @moduledoc false

  use JetFilters.Operator, [
    [:string, :string],
    [:number, :number],
    [:datetime, :datetime]
  ]

  build_to_dynamic([type, type]) do
    dynamic(^op1 < ^op2)
  end
end

defmodule JetFilters.Operator.LTE do
  @moduledoc false

  use JetFilters.Operator, [
    [:string, :string],
    [:number, :number],
    [:datetime, :datetime]
  ]

  build_to_dynamic([type, type]) do
    dynamic(^op1 <= ^op2)
  end
end
