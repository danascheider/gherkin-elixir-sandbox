defmodule GherkinTokenScannerTest do
  use ExUnit.Case
  doctest Gherkin.TokenScanner

  test ".get_raw_tokens\\1 generates EOF token when file is empty" do
    input           = nil
    expected_output = [
      %Gherkin.RawToken{
        location: %{line: 1},
        line: %Gherkin.Line{text: nil, line_number: 1}
      }
    ]

    assert Gherkin.TokenScanner.get_raw_tokens(input) == expected_output
  end

  test ".get_raw_tokens\\1 generates Empty token when file contains blank line" do
    input           = ""
    expected_output = [
      %Gherkin.RawToken{
        location: %{line: 1},
        line: %Gherkin.Line{text: "", line_number: 1}
      },
      %Gherkin.RawToken{
        location: %{line: 2},
        line: %Gherkin.Line{text: nil, line_number: 2}
      }
    ]

    assert Gherkin.TokenScanner.get_raw_tokens(input) == expected_output
  end

  test ".get_raw_tokens\\1 generates tokens" do
    input           = "Feature: See if this works"
    expected_output = [
      %Gherkin.RawToken{
        location: %{line: 1},
        line: %Gherkin.Line{text: "Feature: See if this works", line_number: 1}
      },
      %Gherkin.RawToken{
        location: %{line: 2},
        line: %Gherkin.Line{text: nil, line_number: 2}
      }
    ]

    assert Gherkin.TokenScanner.get_raw_tokens(input) == expected_output
  end

  test ".get_raw_tokens\\1 generates more tokens" do
    input           = "Feature: See if this works\n\n  Scenario: Something else"
    expected_output = [
      %Gherkin.RawToken{
        location: %{line: 1},
        line: %Gherkin.Line{text: "Feature: See if this works", line_number: 1}
      },
      %Gherkin.RawToken{
        location: %{line: 2},
        line: %Gherkin.Line{text: "", line_number: 2}
      },
      %Gherkin.RawToken{
        location: %{line: 3},
        line: %Gherkin.Line{text: "  Scenario: Something else", line_number: 3}
      },
      %Gherkin.RawToken{
        location: %{line: 4},
        line: %Gherkin.Line{text: nil, line_number: 4}
      }
    ]

    assert Gherkin.TokenScanner.get_raw_tokens(input) == expected_output
  end

  test ".get_raw_tokens\\1 generates tokens when the language is set" do
    input           = "language: af\nFeature: See if this works"
    expected_output = [
      %Gherkin.RawToken{
        location: %{line: 1},
        line: %Gherkin.Line{text: "language: af", line_number: 1}
      },
      %Gherkin.RawToken{
        location: %{line: 2},
        line: %Gherkin.Line{text: "Feature: See if this works", line_number: 2}
      },
      %Gherkin.RawToken{
        location: %{line: 3},
        line: %Gherkin.Line{text: nil, line_number: 3}
      }
    ]

    assert Gherkin.TokenScanner.get_raw_tokens(input) == expected_output
  end
end