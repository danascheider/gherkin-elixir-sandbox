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
end