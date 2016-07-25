defmodule Gherkin.DataTable do 
  def ensure_cell_count(rows) do 
    count = List.first(rows) |> Map.get(:cells) |> Enum.count

    Enum.each(rows, fn(row) -> raise_error_if_bad_cell_count(row, count) end)
  end

  def get_cells(row) do
    Enum.map(row.matched_items, fn(cell) -> 
      %{
        type: :TableCell,
        location: cell.location,
        value: cell.matched_text
      }
    end)
  end

  def get_table_rows(ast_node) do
    row_tokens = Gherkin.AstNode.get_tokens(ast_node, :TableRow)
    
    rows = Enum.map(row_tokens, fn({_, row}) ->
      %{
        type: :TableRow,
        location: row.location,
        cells: get_cells(row)
      }
    end)

    ensure_cell_count(rows)

    rows
  end

  defp raise_error_if_bad_cell_count(row, count) do
    if Map.get(row, :cells) |> Enum.count != count do
      loc = Map.get(row, :location)
      raise Gherkin.AstBuilderException, message: "Inconsistent cell count within the table: #{inspect loc}"
    end
  end
end