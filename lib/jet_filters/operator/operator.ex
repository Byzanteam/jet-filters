defmodule JetFilters.Operator do
  @moduledoc false

  defmacro __using__([operand_type | _rest] = operand_types) do
    operand_types =
      if is_list(operand_type) do
        operand_types
      else
        [operand_types]
      end

    quote location: :keep do
      import Ecto.Query
      import unquote(__MODULE__), only: [build_to_dynamic: 2]

      def determine_operand_types(operands, field_types) do
        unquote(__MODULE__).determine_operand_types(
          unquote(operand_types),
          operands,
          field_types
        )
      end
    end
  end

  defmacro build_to_dynamic(operand_type, do: block) when 1 === length(operand_type) do
    quote location: :keep do
      def to_dynamic([op], unquote(operand_type)) do
        var!(op) =
          if is_atom(op) do
            dynamic([q], field(q, ^op))
          else
            op
          end

        unquote(block)
      end
    end
  end

  defmacro build_to_dynamic(operand_type, do: block) when 2 === length(operand_type) do
    quote location: :keep do
      def to_dynamic([op1, op2], unquote(operand_type)) do
        var!(op1) =
          if is_atom(op1) do
            dynamic([q], field(q, ^op1))
          else
            op1
          end

        var!(op2) =
          if is_atom(op2) do
            dynamic([q], field(q, ^op2))
          else
            op2
          end

        unquote(block)
      end
    end
  end

  @operator_modules %{
    "co" => JetFilters.Operator.Co,
    "eq" => JetFilters.Operator.Eq,
    "ew" => JetFilters.Operator.Ew,
    "gt" => JetFilters.Operator.Gt,
    "gte" => JetFilters.Operator.Gte,
    "is_null" => JetFilters.Operator.IsNull,
    "lt" => JetFilters.Operator.Lt,
    "lte" => JetFilters.Operator.Lte,
    "ov" => JetFilters.Operator.Ov,
    "pr" => JetFilters.Operator.Pr,
    "sw" => JetFilters.Operator.Sw
  }

  @spec resolve_operator_module(String.t()) :: {:ok, module()} | :error
  def resolve_operator_module(operator) do
    Map.fetch(@operator_modules, operator)
  end

  @type operand_type() ::
          JetFilters.Type.value_type()
          | {:_var, non_neg_integer()}
          | {:array, {:_var, non_neg_integer()}}
  @type value() :: String.t() | number() | boolean() | DateTime.t() | [String.t()] | [value()]
  @type field() :: atom()

  @spec determine_operand_types(
          valid_operand_types :: [[operand_type()]],
          operands :: [value() | field()],
          field_types :: %{field() => JetFilters.Type.value_type()}
        ) :: {:ok, [JetFilters.Type.value_type()]} | :error
  def determine_operand_types(valid_operand_types, operands, field_types) do
    Enum.find_value(valid_operand_types, :error, &match_type(&1, operands, field_types))
  end

  defp match_type(valid_operand_type, operands, field_types) do
    operand_type =
      Enum.map(operands, fn
        field when is_atom(field) -> Map.fetch!(field_types, field)
        value -> JetFilters.Type.typeof(value)
      end)

    with([_ | _] = operand_type <- do_match_type(valid_operand_type, operand_type)) do
      {:ok, operand_type}
    end
  end

  defp do_match_type(valid_operand_type, operand_type)
       when length(valid_operand_type) === length(operand_type) do
    valid_operand_type
    |> Enum.zip(operand_type)
    |> Enum.reduce_while(%{}, fn {expected_type, actual_type}, var_registry ->
      case type_match?(expected_type, actual_type, var_registry) do
        {:ok, var_registry} -> {:cont, var_registry}
        :error -> {:halt, false}
      end
    end)
    |> case do
      false -> false
      _otherwise -> operand_type
    end
  end

  defp do_match_type(_valid_operand_type, _operand_type), do: false

  defp type_match?({:_var, id}, actual_type, var_registry) do
    case Map.get(var_registry, id) do
      ^actual_type -> {:ok, var_registry}
      nil -> {:ok, Map.put(var_registry, id, actual_type)}
      _otherwise -> :error
    end
  end

  defp type_match?({:array, {:_var, id}}, {:array, actual_type}, var_registry) do
    type_match?({:_var, id}, actual_type, var_registry)
  end

  defp type_match?(expected_type, actual_type, var_registry) do
    if expected_type === actual_type do
      {:ok, var_registry}
    else
      :error
    end
  end
end
