defmodule Gherkin.Token do 
  defstruct line: 1, 
            location: {}, 
            matched_type: :FeatureHeader, 
            matched_text: "", 
            matched_keyword: "Feature",
            matched_indent: 0,
            matched_items: [],
            matched_gherkin_dialect: "en"
end