defmodule JetFilters.Type do
  @moduledoc false

  @type value_type() ::
          :string | :number | :boolean | :datetime | {:array, :string} | {:array, value_type()}

  @spec typeof(term()) :: value_type()
  def typeof(value) when is_binary(value), do: :string
  def typeof(value) when is_number(value), do: :number
  def typeof(value) when is_boolean(value), do: :boolean
  def typeof(value) when is_struct(value, DateTime), do: :datetime

  def typeof([value | _tail]) when not is_list(value), do: {:array, typeof(value)}

  def typeof([[value | _tail1] | _tail2]) when is_binary(value) do
    {:array, {:array, :string}}
  end

  @spec expand_annotation(list()) :: {:ok, DateTime.t()} | :error
  def expand_annotation([value, "datetime"]) do
    case DateTime.from_iso8601(value) do
      {:ok, value, _offset} -> {:ok, value}
      _otherwise -> :error
    end
  end
end
