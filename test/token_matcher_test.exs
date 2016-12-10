defmodule GherkinTokenMatcherTest do
  use ExUnit.Case
  doctest Gherkin.TokenMatcher

  test ".match_tokens/2 matches EOF token" do
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

  test ".match_tokens/2 matches language token" do
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

  test ".match_tokens/2 matches tag token" do
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

  test ".match_tokens/2 matches a feature line token" do
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

  test ".match_tokens/2 matches a scenario line" do
    input           = [
      %Gherkin.RawToken{
        location: %{line: 3},
        line: %Gherkin.Line{text: "  Scenario: User login", line_number: 3}
      }
    ]

    expected_output = [
      %Gherkin.Token{
        matched_type: :ScenarioLine,
        matched_keyword: "Scenario",
        matched_text: "User login",
        matched_indent: 2,
        location: %{line: 3, column: 3}
      }
    ]

    assert Gherkin.TokenMatcher.match_tokens(input) == expected_output
  end

  test ".match_tokens/2 matches a background line" do
    input           = [
      %Gherkin.RawToken{
        location: %{line: 5},
        line: %Gherkin.Line{text: "    Background:", line_number: 5}
      }
    ]

    expected_output = [
      %Gherkin.Token{
        matched_type: :BackgroundLine,
        matched_keyword: "Background",
        matched_text: "",
        matched_indent: 4,
        location: %{line: 5, column: 5}
      }
    ]

    assert Gherkin.TokenMatcher.match_tokens(input) == expected_output
  end

  test ".match_tokens/2 matches a scenario outline line" do
    input           = [
      %Gherkin.RawToken{
        location: %{line: 5},
        line: %Gherkin.Line{text: "    Scenario Outline: Foobar", line_number: 5}
      }
    ]

    expected_output = [
      %Gherkin.Token{
        matched_type: :ScenarioOutlineLine,
        matched_keyword: "Scenario Outline",
        matched_text: "Foobar",
        matched_indent: 4,
        location: %{line: 5, column: 5}
      }
    ]

    assert Gherkin.TokenMatcher.match_tokens(input) == expected_output
  end

  test ".match_tokens/2 matches an examples line" do
    input           = [
      %Gherkin.RawToken{
        location: %{line: 5},
        line: %Gherkin.Line{text: "    Examples:", line_number: 5}
      }
    ]

    expected_output = [
      %Gherkin.Token{
        matched_type: :ExamplesLine,
        matched_keyword: "Examples",
        matched_text: "",
        matched_indent: 4,
        location: %{line: 5, column: 5}
      }
    ]

    assert Gherkin.TokenMatcher.match_tokens(input) == expected_output
  end

  test ".match_tokens/2 matches an Empty token" do
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

    assert Gherkin.TokenMatcher.match_tokens(input) == expected_output
  end

  test ".match_tokens/2 matches a comment" do
    input           = [
      %Gherkin.RawToken{
        location: %{line: 1},
        line: %Gherkin.Line{text: "  # Foo bar baz", line_number: 1}
      }
    ]

    expected_output = [
      %Gherkin.Token{
        matched_type: :Comment,
        matched_indent: 2,
        matched_text: "# Foo bar baz",
        location: %{line: 1, column: 3}
      }
    ]

    assert Gherkin.TokenMatcher.match_tokens(input) == expected_output
  end

  test ".match_tokens/2 matches step tokens" do
    input           = [
      %Gherkin.RawToken{
        location: %{line: 3},
        line: %Gherkin.Line{text: "Given I am a user", line_number: 3}
      },
      %Gherkin.RawToken{
        location: %{line: 4},
        line: %Gherkin.Line{text: "When I fill out the login form", line_number: 4}
      },
      %Gherkin.RawToken{
        location: %{line: 5},
        line: %Gherkin.Line{text: "And I click the submit button", line_number: 5}
      },
      %Gherkin.RawToken{
        location: %{line: 6},
        line: %Gherkin.Line{text: "Then I should see my profile", line_number: 6}
      },
      %Gherkin.RawToken{
        location: %{line: 7},
        line: %Gherkin.Line{text: "But I should not see other users' profiles", line_number: 7}
      }
    ]

    expected_output = [
      %Gherkin.Token{
        matched_type: :StepLine,
        matched_keyword: "Given ",
        matched_text: "I am a user",
        location: %{line: 3, column: 1}
      },
      %Gherkin.Token{
        matched_type: :StepLine,
        matched_keyword: "When ",
        matched_text: "I fill out the login form",
        location: %{line: 4, column: 1}
      },
      %Gherkin.Token{
        matched_type: :StepLine,
        matched_keyword: "And ",
        matched_text: "I click the submit button",
        location: %{line: 5, column: 1}
      },
      %Gherkin.Token{
        matched_type: :StepLine,
        matched_keyword: "Then ",
        matched_text: "I should see my profile",
        location: %{line: 6, column: 1}
      },
      %Gherkin.Token{
        matched_type: :StepLine,
        matched_keyword: "But ",
        matched_text: "I should not see other users' profiles",
        location: %{line: 7, column: 1}
      }
    ]

    assert Gherkin.TokenMatcher.match_tokens(input) == expected_output
  end

  test ".match_tokens/2 matches a docstring separator" do
    input = [
      %Gherkin.RawToken{
        location: %{line: 10},
        line: %Gherkin.Line{text: "   ```", line_number: 10}
      },
      %Gherkin.RawToken{
        location: %{line: 11},
        line: %Gherkin.Line{text: "   \"\"\"", line_number: 11}
      }
    ]

    expected_output = [
      %Gherkin.Token{
        matched_type: :DocStringSeparator,
        matched_indent: 3,
        matched_keyword: "```",
        location: %{line: 10, column: 4}
      },
      %Gherkin.Token{
        matched_type: :DocStringSeparator,
        matched_indent: 3,
        matched_keyword: "\"\"\"",
        location: %{line: 11, column: 4}
      }
    ]

    assert Gherkin.TokenMatcher.match_tokens(input) == expected_output
  end

  test ".match_tokens/2 sets Gherkin dialect correctly" do
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