defmodule Gherkin.TokenScanner do
  def get_raw_tokens(features) when is_nil(features) do
    [
      %Gherkin.RawToken{
        line: %Gherkin.Line{text: nil, line_number: 1},
        location: %{line: 1}
      }
    ]
  end

  def get_raw_tokens(features) when is_list(features) do
    #
  end

  def get_raw_tokens(features) do
    get_raw_tokens(String.split(features, ~r/\n/))
  end
end