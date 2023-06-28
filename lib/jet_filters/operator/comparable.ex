defmodule JetFilters.Operator.Gt do
  @moduledoc false

  use JetFilters.Operator, [
    [:string, :string],
    [:number, :number],
    [:datetime, :datetime]
  ]

  build_to_dynamic([_type1, _type2]) do
    dynamic(^op1 > ^op2)
  end
end

defmodule JetFilters.Operator.Gte do
  @moduledoc false

  use JetFilters.Operator, [
    [:string, :string],
    [:number, :number],
    [:datetime, :datetime]
  ]

  build_to_dynamic([_type1, _type2]) do
    dynamic(^op1 >= ^op2)
  end
end

defmodule JetFilters.Operator.Lt do
  @moduledoc false

  use JetFilters.Operator, [
    [:string, :string],
    [:number, :number],
    [:datetime, :datetime]
  ]

  build_to_dynamic([_type1, _type2]) do
    dynamic(^op1 < ^op2)
  end
end

defmodule JetFilters.Operator.Lte do
  @moduledoc false

  use JetFilters.Operator, [
    [:string, :string],
    [:number, :number],
    [:datetime, :datetime]
  ]

  build_to_dynamic([_type1, _type2]) do
    dynamic(^op1 <= ^op2)
  end
end
