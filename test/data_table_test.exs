defmodule GherkinDataTableTest do
  use ExUnit.Case
  doctest Gherkin.DataTable

  test ".ensure_cell_count\1 when count is consistent returns nil" do 
    rows = [
      %{cells: [:foo, :bar]},
      %{cells: [:bar, :baz]},
      %{cells: [:baz, :qux]}
    ]

    assert Gherkin.DataTable.ensure_cell_count(rows) == :ok
  end

  test ".ensure_cell_count\1 when count is not consistent raises an error" do 
    rows = [
      %{cells: [:foo, :bar]},
      %{cells: [:bar, :baz]},
      %{cells: [:bar, :baz, :qux], location: %{line: 5, column: 12}}
    ]

    message = "Inconsistent cell count within the table: %{column: 12, line: 5}"

    assert_raise(Gherkin.AstBuilderException, message, fn -> 
      Gherkin.DataTable.ensure_cell_count(rows) 
    end)
  end
end