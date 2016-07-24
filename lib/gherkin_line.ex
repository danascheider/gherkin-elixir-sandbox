defmodule Gherkin.GherkinLine do
  defstruct text: "", line_number: 1

  def line_text(line) do 
    line.text
  end

  def trimmed_text(line) do 
    String.trim_leading(line.text)
  end

  def indent(line) do 
    String.length(line_text(line)) - String.length(trimmed_text(line))
  end
end