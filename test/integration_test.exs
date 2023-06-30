defmodule JetFilters.IntegrationTest do
  use ExUnit.Case, async: true

  @moduletag :integration

  alias JetFilters.Exp.Parser
  alias JetFilters.SQL

  setup do
    [
      field_types: %{
        age: :number,
        name: :string,
        tags: {:array, :string},
        inserted_at: :datetime
      }
    ]
  end

  test "works", %{field_types: field_types} do
    assert {:ok, ast} = Parser.parse("gt(age, 10)")
    assert {:ok, _dynamic} = SQL.to_dynamic(ast, field_types)

    assert {:ok, ast} = Parser.parse("gt(age, 10) and eq(name, \"foo\")")
    assert {:ok, _dynamic} = SQL.to_dynamic(ast, field_types)

    assert {:ok, ast} =
             Parser.parse(~s{gt(age, 10) and (eq(name, "foo") or not co(tags, ["foo"]))})

    assert {:ok, _dynamic} = SQL.to_dynamic(ast, field_types)

    assert {:ok, ast} = Parser.parse("gt(inserted_at, \"2023-06-29T05:30:01.323372Z\"::datetime)")
    assert {:ok, _dynamic} = SQL.to_dynamic(ast, field_types)

    assert {:ok, ast} = Parser.parse(~s{co([["a", "b"]], [["x", "y"]])})
    assert {:ok, _dynamic} = SQL.to_dynamic(ast, field_types)
  end

  test "fails", %{field_types: field_types} do
    assert {:error, _reason, _line} = Parser.parse("age > 10")

    assert {:ok, ast} = Parser.parse("gt(age1, 10)")
    assert :error === SQL.to_dynamic(ast, field_types)

    assert {:ok, ast} = Parser.parse("gt(age, \"10\")")
    assert :error === SQL.to_dynamic(ast, field_types)

    assert {:ok, ast} = Parser.parse("co([[1, 2]], [[2, 3]])")
    assert :error === SQL.to_dynamic(ast, field_types)
  end
end
