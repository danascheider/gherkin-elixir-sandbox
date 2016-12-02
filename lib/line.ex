defmodule Gherkin.Line do
  @language_pattern ~r/^\s*#\s*language\s*:\s*([a-zA-Z\-_]+)\s*\z/

  defstruct text: "", line_number: 1

  def trimmed_text(line), do: String.trim_leading(line.text)

  def indent(line), do: String.length(line.text) - String.length(trimmed_text(line))

  def get_rest_trimmed(line, index) do
    text = trimmed_text(line) 
    String.slice(text, index..String.length(text) - 1) |> String.trim
  end

  def is_comment?(line), do: starts_with?(line, "#")

  def is_background_header?(line, language \\ "en") do
    match_title_line(line, Gherkin.Dialect.background_keywords(language))
  end

  def is_eof?(line), do: line.text == nil

  def is_examples_header?(line, language \\ "en") do
    match_title_line(line, Gherkin.Dialect.examples_keywords(language))
  end

  def is_language_header?(line), do: Regex.match?(@language_pattern, line.text)

  def is_feature_header?(line, language \\ "en") do
    match_title_line(line, Gherkin.Dialect.feature_keywords(language))
  end

  def is_scenario_header?(line, language \\ "en") do
    match_title_line(line, Gherkin.Dialect.scenario_keywords(language))
  end

  def is_scenario_outline_header?(line, language \\ "en") do
    match_title_line(line, Gherkin.Dialect.scenario_outline_keywords(language))
  end

  def is_step?(line, language \\ "en") do
    match_step_line(line, Gherkin.Dialect.step_keywords(language))
  end

  def is_table_row?(line) do
    starts_with?(line, "|") && ends_with?(line, "|")
  end

  def is_tags?(line) do
    starts_with?(line, "@")
  end

  def empty?(line), do: trimmed_text(line) == ""

  def is_docstring_separator?(line) do
    separator = ~r/^(\"\"\")|(```)/

    Regex.match?(separator, trimmed_text(line))
  end

  def starts_with?(line, keyword), do: trimmed_text(line) |> String.starts_with?(keyword)

  defp ends_with?(line, keyword), do: String.trim_trailing(line.text) |> String.ends_with?(keyword)

  defp match_title_line(line, keywords) do
    keyword = Enum.find(keywords, fn(keyword) -> starts_with?(line, "#{keyword}:") end)
    !!keyword
  end

  defp match_step_line(line, keywords) do
    !!Enum.find(keywords, fn(keyword) -> starts_with?(line, keyword) end)
  end
end