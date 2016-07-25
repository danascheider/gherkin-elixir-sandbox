defmodule GherkinDataTableTest do
  use ExUnit.Case
  doctest Gherkin.DataTable

  test ".ensure_cell_count\1 when count is consistent returns nil" do 
    rows = [
      %{cells: {:foo, :bar}},
      %{cells: {:bar, :baz}},
      %{cells: {:baz, :qux}}
    ]

    assert Gherkin.DataTable.ensure_cell_count(rows) == nil
  end
end