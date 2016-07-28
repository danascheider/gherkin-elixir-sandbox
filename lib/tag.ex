defmodule Gherkin.Tag do
  defstruct column: 1, text: ""

  def get_tags(tags, col \\ nil) do
    column = col || Gherkin.GherkinLine.indent(tags) + 1
    items  = Gherkin.GherkinLine.trimmed_text(tags) |> String.split(" ")

    add_struct(items, [], column)
  end

  defp add_struct([], structs, new_col), do: structs

  defp add_struct([head | tail], structs, new_col) do
    next_col = String.length(head) + new_col + 1
    struct   = %Gherkin.Tag{column: new_col, text: head}

    add_struct(tail, Enum.concat(structs, [struct]), next_col)
  end
end