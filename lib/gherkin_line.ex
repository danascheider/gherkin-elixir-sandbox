defmodule Gherkin.GherkinLine do
  defstruct text: "", line_number: 1

  def trimmed_text(line) do 
    String.trim_leading(line.text)
  end

  def empty?(line) do 
    trimmed_text(line) == ""
  end

  def get_line_text(line, indent_to_remove) do
    if indent_to_remove > String.length(line.text) || indent_to_remove < 0 do
      line.text
    else
      String.slice(line.text, indent_to_remove..String.length(line.text) - 1)
    end
  end

  def indent(line) do 
    String.length(line_text(line)) - String.length(trimmed_text(line))
  end

  def starts_with?(line, keyword) do 
    String.starts_with?(trimmed_text(line), keyword)
  end

  def starts_with_title_keyword?(line, keyword) do 
    starts_with?(line, "#{keyword}:")
  end

  def get_rest_trimmed(line, index) do 
    text = trimmed_text(line)
    String.slice(text, index..String.length(text) - 1) |> String.trim
  end

  defp line_text(line) do 
    line.text
  end
end