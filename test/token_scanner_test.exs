defmodule GherkinTokenScannerTest do
  use ExUnit.Case
  doctest Gherkin.TokenScanner

  test ".get_raw_tokens\\1 generates EOF when file is empty" do
    input           = nil
    expected_output = [
      %Gherkin.RawToken{
        location: %{line: 1},
        line: %Gherkin.Line{text: nil, line_number: 1}
      }
    ]

    assert Gherkin.TokenScanner.get_raw_tokens(input) == expected_output
  end

  # test ".get_tokens\\2 generates tokens" do
  #   input           = "Feature: See if this works"
  #   expected_output = [
  #     %Gherkin.RawToken{
  #       location: %{line: 1},
  #       line: %Gherkin.Line{text: "Feature: See if this works", line_number: 1}
  #     },
  #     %Gherkin.RawToken{
  #       location: %{line: 2},
  #       line: %Gherkin.Line{text: nil, line_number: 2}
  #     }
  #   ]

  #   assert Gherkin.TokenScanner.get_raw_tokens(input) == expected_output
  # end
end