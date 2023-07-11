defmodule JetFilters.SQL do
  @moduledoc false

  import Ecto.Query

  # credo:disable-for-next-line Credo.Check.Warning.SpecWithStruct
  @spec to_dynamic(
          JetFilters.Exp.Parser.ast(),
          field_types :: %{(field :: atom()) => JetFilters.Type.value_type()}
        ) :: {:ok, %Ecto.Query.DynamicExpr{}} | :error
  def to_dynamic(ast, field_types) do
    do_to_dynamic(ast, field_types)
  end

  defp do_to_dynamic({{:id, operator}, _line, operands}, field_types) do
    with(
      {:ok, module} <- JetFilters.Operator.resolve_operator_module(operator),
      {:ok, operands} <- normalize_operands(operands),
      {:ok, operand_type} <- module.determine_operand_types(operands, field_types)
    ) do
      {:ok, module.to_dynamic(operands, operand_type)}
    end
  end

  defp do_to_dynamic({:and, _line, [ast | asts]}, field_types) do
    with({:ok, d} <- to_dynamic(ast, field_types)) do
      Enum.reduce_while(asts, {:ok, d}, fn ast, {:ok, acc} ->
        case to_dynamic(ast, field_types) do
          {:ok, d} -> {:cont, {:ok, dynamic(^acc and ^d)}}
          :error -> {:halt, :error}
        end
      end)
    end
  end

  defp do_to_dynamic({:or, _line, [ast | asts]}, field_types) do
    with({:ok, d} <- to_dynamic(ast, field_types)) do
      Enum.reduce_while(asts, {:ok, d}, fn ast, {:ok, acc} ->
        case to_dynamic(ast, field_types) do
          {:ok, d} -> {:cont, {:ok, dynamic(^acc or ^d)}}
          :error -> {:halt, :error}
        end
      end)
    end
  end

  defp do_to_dynamic({:not, _linne, [ast]}, field_types) do
    with({:ok, d} <- to_dynamic(ast, field_types)) do
      {:ok, dynamic(not (^d))}
    end
  end

  defp do_to_dynamic(_ast, _field_types), do: :error

  defp normalize_operands(operands) do
    operands
    |> Enum.reduce_while({:ok, []}, fn
      {:id, _line, id}, {:ok, acc} ->
        # credo:disable-for-next-line Credo.Check.Warning.UnsafeToAtom
        {:cont, {:ok, [String.to_atom(id) | acc]}}

      {:"::", _line, annotation}, {:ok, acc} ->
        case JetFilters.Type.expand_annotation(annotation) do
          {:ok, value} -> {:cont, {:ok, [value | acc]}}
          :error -> {:halt, :error}
        end

      literal, {:ok, acc} ->
        {:cont, {:ok, [literal | acc]}}
    end)
    |> case do
      {:ok, operands} -> {:ok, Enum.reverse(operands)}
      :error -> :error
    end
  end
end
