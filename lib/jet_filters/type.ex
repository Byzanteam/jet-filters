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

  @spec expand_type([
          value_type() | {:_var, non_neg_integer()} | {:array, {:_var, non_neg_integer()}}
        ]) :: [[value_type()]]
  def expand_type(type) do
    vars =
      Enum.reduce(type, MapSet.new(), fn
        {:_var, i}, acc -> MapSet.put(acc, i)
        {:array, {:_var, i}}, acc -> MapSet.put(acc, i)
        _otherwise, acc -> acc
      end)

    do_expand_type(type, MapSet.to_list(vars))
  end

  defp do_expand_type(type, []), do: [type]

  defp do_expand_type(type, [var | vars]) do
    types =
      Enum.map(all_types(), fn t ->
        Enum.map(type, fn
          {:_var, ^var} -> t
          {:array, {:_var, ^var}} -> {:array, t}
          otherwise -> otherwise
        end)
      end)

    Enum.flat_map(types, &do_expand_type(&1, vars))
  end

  @spec expand_annotation(list()) :: {:ok, DateTime.t()} | :error
  def expand_annotation([value, "datetime"]) do
    case DateTime.from_iso8601(value) do
      {:ok, value, _offset} -> {:ok, value}
      _otherwise -> :error
    end
  end

  defp all_types do
    types = [:string, :number, :boolean, :datetime, {:array, :string}]
    types ++ Enum.map(types, &{:array, &1})
  end
end
