defmodule Gherkin.TokenScanner do
  def get_raw_tokens([], line_number) do
    [
      %Gherkin.RawToken{
        line: %Gherkin.Line{text: nil, line_number: line_number},
        location: %{line: line_number}
      }
    ]
  end

  def get_raw_tokens([head | tail], line_number) do
    [
      %Gherkin.RawToken{
        line: %Gherkin.Line{text: head, line_number: line_number},
        location: %{line: line_number}
      }
    ] ++ get_raw_tokens(tail, line_number + 1)
  end

  def get_raw_tokens(nil) do
    [
      %Gherkin.RawToken{
        line: %Gherkin.Line{text: nil, line_number: 1},
        location: %{line: 1}
      }
    ]
  end

  def get_raw_tokens(features) do
    get_raw_tokens(String.split(features, ~r/\n/), 1)
  end
end