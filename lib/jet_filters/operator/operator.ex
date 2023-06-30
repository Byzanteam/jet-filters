defmodule JetFilters.Operator do
  @moduledoc false

  defmacro __using__([operand_type | _rest] = operand_types) do
    operand_types =
      if is_list(operand_type) do
        operand_types
      else
        [operand_types]
      end

    type_matchers =
      operand_types
      |> Enum.flat_map(&JetFilters.Type.expand_type/1)
      |> Enum.map(&type_matcher/1)

    quote location: :keep do
      import Ecto.Query
      import unquote(__MODULE__), only: [build_to_dynamic: 2]

      @type value() :: unquote(__MODULE__).value()
      @type field() :: unquote(__MODULE__).field()

      @spec determine_operand_types(operands :: [value() | field()],
              field_types: %{field() => JetFilters.Type.value_type()}
            ) :: {:ok, [JetFilters.Type.value_type()]} | :error
      def determine_operand_types(operands, field_types) do
        with(
          {:ok, operand_type} <- unquote(__MODULE__).build_operand_type(operands, field_types)
        ) do
          match_type(operand_type)
        end
      end

      unquote(type_matchers)

      defp match_type(_operand_type), do: :error
    end
  end

  @type value() :: String.t() | number() | boolean() | DateTime.t() | [String.t()] | [value()]
  @type field() :: atom()

  @spec build_operand_type(operands :: [value() | field()],
          field_types: %{field() => JetFilters.Type.value_type()}
        ) :: {:ok, [JetFilters.Type.value_type()]} | :error
  def build_operand_type(operands, field_types) do
    operands
    |> Enum.reduce_while({:ok, []}, fn
      field, {:ok, acc} when is_atom(field) ->
        case Map.fetch(field_types, field) do
          {:ok, type} -> {:cont, {:ok, [type | acc]}}
          :error -> {:halt, :error}
        end

      value, {:ok, acc} ->
        case JetFilters.Type.typeof(value) do
          {:ok, type} -> {:cont, {:ok, [type | acc]}}
          :error -> {:halt, :error}
        end
    end)
    |> case do
      {:ok, operand_type} ->
        {:ok, Enum.reverse(operand_type)}

      :error ->
        :error
    end
  end

  defp type_matcher(operand_type) do
    quote location: :keep, generated: true do
      defp match_type(unquote(operand_type)), do: {:ok, unquote(operand_type)}
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
    "co" => JetFilters.Operator.CO,
    "eq" => JetFilters.Operator.EQ,
    "ew" => JetFilters.Operator.EW,
    "gt" => JetFilters.Operator.GT,
    "gte" => JetFilters.Operator.GTE,
    "is_null" => JetFilters.Operator.IsNull,
    "lt" => JetFilters.Operator.LT,
    "lte" => JetFilters.Operator.LTE,
    "ov" => JetFilters.Operator.OV,
    "pr" => JetFilters.Operator.PR,
    "sw" => JetFilters.Operator.SW
  }

  @spec resolve_operator_module(String.t()) :: {:ok, module()} | :error
  def resolve_operator_module(operator) do
    Map.fetch(@operator_modules, operator)
  end
end
