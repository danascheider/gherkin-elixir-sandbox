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
        ],
        matched_indent: 3,
        location: %{line: 1, column: 4}
      }
    ]

    assert Gherkin.TokenMatcher.match_tokens(input) == expected_output
  end

  test ".match_tokens\\1 matches a feature line token" do
    input           = [
      %Gherkin.RawToken{
        location: %{line: 1},
        line: %Gherkin.Line{text: "Feature: See if this works", line_number: 1}
      }
    ]

    expected_output = [
      %Gherkin.Token{
        matched_type: :FeatureLine,
        matched_keyword: "Feature",
        matched_text: "See if this works",
        location: %{line: 1, column: 1}
      }
    ]

    assert Gherkin.TokenMatcher.match_tokens(input) == expected_output
  end

  test ".match_tokens\\1 matches an Empty token" do
    input           = [
      %Gherkin.RawToken{
        location: %{line: 1},
        line: %Gherkin.Line{text: "   ", line_number: 1}
      }
    ]

    expected_output = [
      %Gherkin.Token{
        matched_type: :Empty,
        matched_text: nil,
        location: %{line: 1, column: 1}
      }
    ]
  end

  test ".match_tokens\\1 sets Gherkin dialect correctly" do
    input           = [
      %Gherkin.RawToken{
        location: %{line: 1},
        line: %Gherkin.Line{text: "# language: it", line_number: 1}
      },
      %Gherkin.RawToken{
        location: %{line: 2},
        line: %Gherkin.Line{text: "", line_number: 2}
      },
      %Gherkin.RawToken{
        location: %{line: 3},
        line: %Gherkin.Line{text: nil, line_number: 3}
      }
    ]

    expected_output = [
      %Gherkin.Token{
        matched_type: :Language,
        matched_text: "it",
        matched_gherkin_dialect: "it",
        location: %{line: 1, column: 1}
      },
      %Gherkin.Token{
        matched_type: :Empty,
        matched_gherkin_dialect: "it",
        location: %{line: 2, column: 1}
      },
      %Gherkin.Token{
        matched_type: :EOF,
        matched_gherkin_dialect: "it",
        location: %{line: 3, column: 1}
      }
    ]

    assert Gherkin.TokenMatcher.match_tokens(input) == expected_output
  end
end