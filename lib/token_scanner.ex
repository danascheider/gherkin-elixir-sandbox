defmodule Gherkin.TokenScanner do
  def get_lines(document_body) do
    lines = String.split(document_body, "\n")

    Enum.zip(1..Enum.count(lines), lines)
    |> Enum.map(fn {line_number, line} ->
         %Gherkin.GherkinLine{text: line, line_number: line_number}
       end)
  end
end