defmodule Gherkin.TokenMatcher do 
  @language_pattern ~r/^\s*#\s*language\s*:\s*([a-zA-Z\-_]+)\s*$/

  def match_tag_line(token) do
    Gherkin.GherkinLine.starts_with?(token.line, "@")
  end

  def match_title_line(token, token_type, keywords) do
    keyword = Enum.find(keywords, fn(keyword) -> 
      Gherkin.GherkinLine.starts_with_title_keyword?(token.line, keyword)
    end)

    if keyword do
      title = Gherkin.GherkinLine.get_rest_trimmed(token.line, String.length(keyword) + 1)

      %{
        token |
        matched_type: token_type,
        matched_text: title,
        matched_keyword: keyword
      }
    else
      false
    end
  end
end