defmodule Gherkin.TokenMatcher do
  def match_tokens([]) do
    []
  end

  def match_tokens([head | tail]) do
     [ match_token(head) ] ++ match_tokens(tail)
  end

  defp match_token(%Gherkin.RawToken{line: %Gherkin.Line{text: nil, line_number: _}, location: _}) do
    %Gherkin.Token{
      matched_type: :EOF
    }
  end

  defp match_token(raw_token) do
    cond do
      Gherkin.Line.is_language_header?(raw_token.line) ->
        dialect_name = Regex.run(~r/([a-zA-Z\-_]+)\s*\z/, raw_token.line.text) |> Enum.at(0)

        %Gherkin.Token{
          matched_type: :Language,
          matched_gherkin_dialect: dialect_name,
          matched_text: dialect_name
        }

      Gherkin.Line.is_tags?(raw_token.line) ->
        tags = Gherkin.Tag.tags(raw_token.line.text)

        %Gherkin.Token{
          matched_type: :TagLine,
          matched_items: tags
        }
    end
  end
end