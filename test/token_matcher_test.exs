defmodule GherkinTokenMatcherTest do
  use ExUnit.Case
  doctest Gherkin.TokenMatcher

  test ".match_tokens\\1 matches EOF token" do
    input           = [
      %Gherkin.RawToken{
        location: %{line: 1},
        line: %Gherkin.Line{text: nil, line_number: 1}
      }
    ]

    expected_output = [
      %Gherkin.Token{
        matched_type: :EOF,
        location: %{line: 1, column: 1}
      }
    ]

    assert Gherkin.TokenMatcher.match_tokens(input) == expected_output
  end

  test ".match_tokens\\1 matches language token" do
    input           = [
      %Gherkin.RawToken{
        location: %{line: 1},
        line: %Gherkin.Line{text: "# language: it", line_number: 1}
      }
    ]

    expected_output = [
      %Gherkin.Token{
        matched_type: :Language,
        matched_text: "it",
        matched_gherkin_dialect: "it",
        location: %{line: 1, column: 1}
      }
    ]

    assert Gherkin.TokenMatcher.match_tokens(input) == expected_output
  end

  test ".match_tokens\\1 matches tag token" do
    input           = [
      %Gherkin.RawToken{
        location: %{line: 1},
        line: %Gherkin.Line{text: "   @one @two @three", line_number: 1}
      }
    ]

    expected_output = [
      %Gherkin.Token{
        matched_type: :TagLine,
        matched_items: [
          %Gherkin.Tag{text: "one", column: 4},
          %Gherkin.Tag{text: "two", column: 9},
          %Gherkin.Tag{text: "three", column: 14}
        ]
      }
    ]

    assert Gherkin.TokenMatcher.match_tokens(input) == expected_output
  end
end