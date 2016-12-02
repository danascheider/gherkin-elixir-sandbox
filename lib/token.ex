defmodule Gherkin.Token do
  defstruct matched_type: :GherkinDocument, 
            matched_text: "",
            matched_keyword: "",
            matched_indent: 0,
            matched_items: [],
            matched_gherkin_dialect: "en"
end