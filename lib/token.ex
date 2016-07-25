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

  def get_location(token), do: token.location

  def get_location(token, column), do: Map.merge(token.location, %{column: column})
end