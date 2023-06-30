defmodule JetFilters.Type do
  @moduledoc false

  @type basic_value_type() :: :string | :number | :boolean | :datetime | {:array, :string}
  @type value_type() :: basic_value_type() | {:array, basic_value_type()}

  @basic_value_types [:string, :number, :boolean, :datetime, {:array, :string}]
  @value_types @basic_value_types ++ Enum.map(@basic_value_types, &{:array, &1})

  @spec typeof(term()) :: {:ok, value_type()} | :error
  def typeof(value) when is_binary(value), do: {:ok, :string}
  def typeof(value) when is_number(value), do: {:ok, :number}
  def typeof(value) when is_boolean(value), do: {:ok, :boolean}
  def typeof(value) when is_struct(value, DateTime), do: {:ok, :datetime}

  def typeof([value | _tail]) when not is_list(value) do
    with({:ok, type} <- typeof(value)) do
      {:ok, {:array, type}}
    end
  end

  def typeof([[value | _tail1] | _tail2]) when is_binary(value) do
    {:ok, {:array, {:array, :string}}}
  end

  def typeof(_value), do: :error

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
    @value_types
    |> Stream.map(fn t ->
      List.foldr(type, [], fn
        {:_var, ^var}, acc -> [t | acc]
        {:array, {:_var, ^var}}, acc when t in @basic_value_types -> [{:array, t} | acc]
        {:array, {:_var, ^var}}, acc -> acc
        otherwise, acc -> [otherwise | acc]
      end)
    end)
    |> Stream.reject(&(&1 === []))
    |> Enum.flat_map(&do_expand_type(&1, vars))
  end

  @spec expand_annotation(list()) :: {:ok, DateTime.t()} | :error
  def expand_annotation([value, "datetime"]) do
    case DateTime.from_iso8601(value) do
      {:ok, value, _offset} -> {:ok, value}
      _otherwise -> :error
    end
  end
end
