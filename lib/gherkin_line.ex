defmodule Gherkin.GherkinLine do
  defstruct text: "", line_number: 1

  def line_text(line) do 
    line.text
  end
end