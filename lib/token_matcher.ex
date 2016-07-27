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
      true
    else
      false
    end
  end
end