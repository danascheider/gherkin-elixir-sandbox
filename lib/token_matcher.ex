defmodule Gherkin.TokenMatcher do
  def match_tokens(list, context \\ %Gherkin.ParserContext{})

  def match_tokens([], _context) do
    []
  end

  def match_tokens([head | tail], context) do
    token_matched       = match_token(head, context)
    dialect             = token_matched.matched_gherkin_dialect || context.language
    separator           = set_separator(token_matched, context)

    new_context = %{language: dialect, active_docstring_separator: separator}

    [ match_token(head, new_context) ] ++ match_tokens(tail, new_context)
  end

  defp set_separator(token, context) do
    if token.matched_type == :DocStringSeparator do
      cond do
        context.active_docstring_separator == nil -> token.matched_text
        context.active_docstring_separator == token.matched_text -> nil
        true -> context.active_docstring_separator
      end
    else
      context.active_docstring_separator
    end
  end

  def match_token(%{line: %{text: nil, line_number: num}}, context) do
    %Gherkin.Token{
      matched_type: :EOF,
      matched_indent: 0,
      matched_gherkin_dialect: context.language,
      location: %{line: num, column: 1}
    }
  end

  def match_token(raw_token, context) do
    token = %Gherkin.Token{
      matched_indent: Gherkin.Line.indent(raw_token.line),
      location: %{line: raw_token.line.line_number, column: Gherkin.Line.indent(raw_token.line) + 1},
      matched_gherkin_dialect: context.language
    }

    cond do
      Gherkin.Line.is_language_header?(raw_token.line) ->
        dialect_name = Regex.run(~r/([a-zA-Z\-_]+)\s*\z/, raw_token.line.text) |> Enum.at(0)

        %{ token |
          matched_type: :Language,
          matched_gherkin_dialect: dialect_name,
          matched_text: dialect_name
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

      Gherkin.Line.is_docstring_separator?(raw_token.line) ->
        %{ token |
          matched_type: :DocStringSeparator,
          matched_keyword: Gherkin.Line.trimmed_text(raw_token.line)
        }

      keyword = Gherkin.Line.is_step?(raw_token.line, context.language) ->
        text = String.replace_leading(raw_token.line.text, keyword, "")

        %{ token |
          matched_type: :StepLine,
          matched_keyword: keyword,
          matched_text: text
        }

      Gherkin.Line.is_header?(raw_token.line, context.language) ->
        {keyword, text} = Gherkin.Line.header_elements(raw_token.line, Gherkin.Dialect.header_keywords(context.language))
        matched_type    = Gherkin.Line.header_type(keyword, context.language)

        %{ token |
          matched_type: matched_type,
          matched_keyword: keyword,
          matched_text: text
        }

      Gherkin.Line.is_comment?(raw_token.line) ->
        %{ token |
          matched_type: :Comment,
          matched_text: Gherkin.Line.trimmed_text(raw_token.line)
        }
    end
  end
end