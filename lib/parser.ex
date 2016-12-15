defmodule Gherkin.Parser do
  def parse(nil, _url) do
    Gherkin.TokenScanner.get_raw_tokens([], 1)
      |> Gherkin.TokenMatcher.match_tokens(%Gherkin.ParserContext{})
  end

  def parse(input, _url) do
    # Put the input in lexable form
    String.split(input, ~r/\n/) 
      |> Gherkin.TokenScanner.get_raw_tokens(1)
      |> Gherkin.TokenMatcher.match_tokens(%Gherkin.ParserContext{})
  end
end