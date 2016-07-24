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
end