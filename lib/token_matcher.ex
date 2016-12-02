defmodule Gherkin.TokenMatcher do
  @language_pattern ~r/^\s*#\s*language\s*:\s*([a-zA-Z\-_]+)\s*\z/

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
    if Regex.match?(@language_pattern, Gherkin.Line.trimmed_text(raw_token.line)) do
      dialect_name = Regex.run(~r/([a-zA-Z\-_]+)\s*\z/, raw_token.line.text) |> Enum.at(0)

      %Gherkin.Token{
        matched_type: :Language,
        matched_gherkin_dialect: dialect_name,
        matched_text: dialect_name
      }
    else
      # something else
    end
  end
end