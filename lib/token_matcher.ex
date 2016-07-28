defmodule Gherkin.TokenMatcher do 
  @language_pattern ~r/^\s*#\s*language\s*:\s*([a-zA-Z\-_]+)\s*$/

  def match_tag_line(token) do
    if Gherkin.GherkinLine.starts_with?(token.line, "@") do
      %{token | matched_type: :TagLine, matched_items: Gherkin.Tag.get_tags(token.line) }
    else
      false
    end
  end

  def match_feature_line(token, language \\ "en") do
    feature_keywords = Gherkin.Dialect.feature_keywords(language)

    match_title_line(token, :FeatureLine, feature_keywords)
  end

  def match_scenario_line(token, language \\ "en") do
    scenario_keywords = Gherkin.Dialect.scenario_keywords(language)

    match_title_line(token, :ScenarioLine, scenario_keywords)
  end

  def match_scenario_outline_line(token, language \\ "en") do
    scenario_outline_keywords = Gherkin.Dialect.scenario_outline_keywords(language)

    match_title_line(token, :ScenarioOutlineLine, scenario_outline_keywords)
  end

  def match_background_line(token, language \\ "en") do
    background_keywords = Gherkin.Dialect.background_keywords(language)

    match_title_line(token, :BackgroundLine, background_keywords)
  end

  def match_examples_line(token, language \\ "en") do
    examples_keywords = Gherkin.Dialect.examples_keywords(language)

    match_title_line(token, :ExamplesLine, examples_keywords)
  end

  def match_table_row(token) do
    if Gherkin.GherkinLine.starts_with?(token.line, "|") do
      %{
        token |
        matched_type: :TableRow,
        matched_items: Gherkin.DataTable.get_cells(token)
      }
    else
      false
    end
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