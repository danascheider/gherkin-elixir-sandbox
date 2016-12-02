defmodule Gherkin.TokenMatcher do
  def match_tokens(list, language \\ "en")

  def match_tokens([], _language) do
    []
  end

  def match_tokens([head | tail], language) do
    dialect = match_token(head, language).matched_gherkin_dialect || language

    [ match_token(head, dialect) ] ++ match_tokens(tail, dialect)
  end

  defp match_token(%Gherkin.RawToken{line: %Gherkin.Line{text: nil, line_number: num}, location: _}, language) do
    %Gherkin.Token{
      matched_type: :EOF,
      matched_indent: 0,
      matched_gherkin_dialect: language,
      location: %{line: num, column: 1}
    }
  end

  defp match_token(raw_token, language) do
    cond do
      Gherkin.Line.is_language_header?(raw_token.line) ->
        dialect_name = Regex.run(~r/([a-zA-Z\-_]+)\s*\z/, raw_token.line.text) |> Enum.at(0)

        %Gherkin.Token{
          matched_type: :Language,
          matched_indent: Gherkin.Line.indent(raw_token.line),
          matched_gherkin_dialect: dialect_name,
          matched_text: dialect_name,
          location: %{line: raw_token.line.line_number, column: Gherkin.Line.indent(raw_token.line) + 1}
        }

      Gherkin.Line.is_tags?(raw_token.line) ->
        tags = Gherkin.Tag.tags(raw_token.line.text)

        %Gherkin.Token{
          matched_type: :TagLine,
          matched_items: tags,
          matched_indent: Gherkin.Line.indent(raw_token.line),
          matched_gherkin_dialect: language,
          location: %{line: raw_token.line.line_number, column: Gherkin.Line.indent(raw_token.line) + 1}
        }

      Gherkin.Line.empty?(raw_token.line) ->
        %Gherkin.Token{
          matched_type: :Empty,
          matched_indent: 0,
          matched_gherkin_dialect: language,
          location: %{line: raw_token.line.line_number, column: 1}
        }

      Gherkin.Line.is_feature_header?(raw_token.line) ->
        keyword = Gherkin.Dialect.feature_keywords(language) 
                  |> Enum.find(fn(keyword) -> Gherkin.Line.starts_with?(raw_token.line, keyword) end)

        %Gherkin.Token{
          matched_type: :FeatureLine,
          matched_indent: Gherkin.Line.indent(raw_token.line),
          matched_gherkin_dialect: language,
          matched_keyword: keyword,
          matched_text: String.replace(Gherkin.Line.trimmed_text(raw_token.line), "#{keyword}: ", ""),
          location: %{line: raw_token.line.line_number, column: Gherkin.Line.indent(raw_token.line) + 1}
        }

      Gherkin.Line.is_scenario_header?(raw_token.line) ->
        keyword = Gherkin.Dialect.scenario_keywords(language)
                  |> Enum.find(fn(keyword) -> Gherkin.Line.starts_with?(raw_token.line, keyword) end)

        %Gherkin.Token{
          matched_type: :ScenarioLine,
          matched_indent: Gherkin.Line.indent(raw_token.line),
          matched_gherkin_dialect: language,
          matched_keyword: keyword,
          matched_text: String.replace(Gherkin.Line.trimmed_text(raw_token.line), "#{keyword}: ", ""),
          location: %{line: raw_token.line.line_number, column: Gherkin.Line.indent(raw_token.line) + 1}
        }
    end
  end
end