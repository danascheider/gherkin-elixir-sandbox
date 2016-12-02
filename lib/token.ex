defmodule Gherkin.Token do
  defstruct matched_type: :GherkinDocument, 
            matched_text: nil,
            matched_keyword: nil,
            matched_indent: 0,
            matched_items: [],
            matched_gherkin_dialect: "en",
            location: %{line: 1, column: 1}
end