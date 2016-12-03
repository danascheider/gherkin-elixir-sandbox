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

    token = %Gherkin.Token{
      matched_indent: Gherkin.Line.indent(raw_token.line),
      location: %{line: raw_token.line.line_number, column: Gherkin.Line.indent(raw_token.line) + 1},
      matched_gherkin_dialect: language
    }

    cond do
      Gherkin.Line.is_language_header?(raw_token.line) ->
        dialect_name = Regex.run(~r/([a-zA-Z\-_]+)\s*\z/, raw_token.line.text) |> Enum.at(0)

        %{ token |
          matched_type: :Language,
          matched_gherkin_dialect: dialect_name,
          matched_text: dialect_name,
        }

      Gherkin.Line.is_tags?(raw_token.line) ->
        tags = Gherkin.Tag.tags(raw_token.line.text)

        %{ token |
          matched_type: :TagLine,
          matched_items: tags,
        }

      Gherkin.Line.empty?(raw_token.line) ->
        %{ token |
          matched_type: :Empty,
          matched_indent: 0,
          location: %{line: raw_token.line.line_number, column: 1}
        }

      Gherkin.Line.is_feature_header?(raw_token.line) ->
        {keyword, text} = Gherkin.Line.header_elements(raw_token.line, Gherkin.Dialect.feature_keywords(language))

        %{ token |
          matched_type: :FeatureLine,
          matched_keyword: keyword,
          matched_text: text,
        }

      Gherkin.Line.is_scenario_header?(raw_token.line) ->
        {keyword, text} = Gherkin.Line.header_elements(raw_token.line, Gherkin.Dialect.scenario_keywords(language))

        %{ token |
          matched_type: :ScenarioLine,
          matched_keyword: keyword,
          matched_text: text,
        }

      Gherkin.Line.is_background_header?(raw_token.line) ->
        {keyword, text} = Gherkin.Line.header_elements(raw_token.line, Gherkin.Dialect.background_keywords(language))

        %{ token |
          matched_type: :BackgroundLine,
          matched_keyword: keyword,
          matched_text: text
        }

      Gherkin.Line.is_scenario_outline_header?(raw_token.line) ->
        {keyword, text} = Gherkin.Line.header_elements(raw_token.line, Gherkin.Dialect.scenario_outline_keywords(language))

        %{ token |
          matched_type: :ScenarioOutlineLine,
          matched_keyword: keyword,
          matched_text: text,
        }

      Gherkin.Line.is_examples_header?(raw_token.line) ->
        {keyword, text} = Gherkin.Line.header_elements(raw_token.line, Gherkin.Dialect.examples_keywords(language))

        %{ token |
          matched_type: :ExamplesLine,
          matched_keyword: keyword,
          matched_text: text
        }

      Gherkin.Line.is_comment?(raw_token.line) ->
        %{ token |
          matched_type: :Comment,
          matched_text: Gherkin.Line.trimmed_text(raw_token.line),
        }
    end
  end
end