defmodule Gherkin.Token do 
  defstruct line: nil, 
            location: {}, 
            matched_type: :FeatureHeader, 
            matched_text: "", 
            matched_keyword: "Feature",
            matched_indent: 0,
            matched_items: [],
            matched_gherkin_dialect: "en"

  def eof?(token), do: token.line == nil

  def token_value(token) do 
    if eof?(token) do 
      "EOF"
    else
      Gherkin.GherkinLine.get_line_text(token.line, -1)
    end
  end
end