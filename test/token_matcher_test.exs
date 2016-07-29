defmodule GherkinTokenMatcherTest do 
  use ExUnit.Case
  doctest Gherkin.TokenMatcher

  test ".match_tag_line\\1 when the line doesn't match returns false" do
    token = %Gherkin.Token{line: %Gherkin.GherkinLine{text: "Foo bar baz"}}

    assert Gherkin.TokenMatcher.match_tag_line(token) == false
  end

  test ".match_tag_line\\1 when the line matches updates the matched items" do
    token = %Gherkin.Token{
      line: %Gherkin.GherkinLine{text: "@foo @bar @baz"}
    }

    expected_output = %Gherkin.Token{
      line: %Gherkin.GherkinLine{text: "@foo @bar @baz"},
      matched_type: :TagLine,
      matched_items: Gherkin.Tag.get_tags(token.line)
    }

    assert Gherkin.TokenMatcher.match_tag_line(token) == expected_output
  end

  test ".match_feature_line\\2 returns false when the line doesn't match" do
    type  = :FeatureLine
    token = %Gherkin.Token{matched_type: type, line: %Gherkin.GherkinLine{text: "Foo bar baz"}}

    assert Gherkin.TokenMatcher.match_feature_line(token) == false
  end

  test ".match_feature_line\\2 updates the token when the line matches" do
    type     = :FeatureLine
    token    = %Gherkin.Token{matched_type: type, line: %Gherkin.GherkinLine{text: "Feature: Hello world"}}

    expected_output = %Gherkin.Token{
      line: %Gherkin.GherkinLine{text: "Feature: Hello world"},
      matched_type: :FeatureLine,
      matched_keyword: "Feature",
      matched_text: "Hello world"
    }

    assert Gherkin.TokenMatcher.match_feature_line(token) == expected_output
  end

  test ".match_feature_line\\2 updates the token when the line matches in another language" do
    language = "it"
    type     = :FeatureLine
    token    = %Gherkin.Token{matched_type: type, matched_gherkin_dialect: language, line: %Gherkin.GherkinLine{text: "Funzionalità: Buon giorno mondo"}}

    expected_output = %Gherkin.Token{
      line: %Gherkin.GherkinLine{text: "Funzionalità: Buon giorno mondo"},
      matched_type: :FeatureLine,
      matched_keyword: "Funzionalità",
      matched_text: "Buon giorno mondo",
      matched_gherkin_dialect: language
    }

    assert Gherkin.TokenMatcher.match_feature_line(token, language) == expected_output
  end

  test ".match_scenario_line\\2 updates the token when the token doesn't match" do
    type  = :ScenarioLine
    token = %Gherkin.Token{matched_type: type, line: %Gherkin.GherkinLine{text: "Foo bar baz"}}

    assert Gherkin.TokenMatcher.match_scenario_line(token) == false
  end

  test ".match_scenario_line\\2 updates the token when the token matches" do
    type  = :ScenarioLine
    token = %Gherkin.Token{matched_type: type, line: %Gherkin.GherkinLine{text: "Scenario: Hello world"}}

    expected_output = %Gherkin.Token{
      matched_type: type,
      line: %Gherkin.GherkinLine{text: "Scenario: Hello world"},
      matched_text: "Hello world",
      matched_keyword: "Scenario"
    }

    assert Gherkin.TokenMatcher.match_scenario_line(token) == expected_output
  end

  test ".match_scenario_line\\2 updates the token when the token matches in another language" do
    lang  = "es"
    type  = :ScenarioLine
    token = %Gherkin.Token{matched_type: type, matched_gherkin_dialect: lang, line: %Gherkin.GherkinLine{text: "Escenario: Hola mundo"}}

    expected_output = %Gherkin.Token{
      matched_type: type,
      line: %Gherkin.GherkinLine{text: "Escenario: Hola mundo"},
      matched_text: "Hola mundo",
      matched_keyword: "Escenario",
      matched_gherkin_dialect: lang
    }

    assert Gherkin.TokenMatcher.match_scenario_line(token, lang) == expected_output
  end

  test ".match_scenario_outline_line\\2 returns false when the line doesn't match" do
    token = %Gherkin.Token{line: %Gherkin.GherkinLine{text: "Foo: bar baz"}}

    assert Gherkin.TokenMatcher.match_scenario_outline_line(token) == false
  end

  test ".match_scenario_outline_line\\2 updates the token when the line matches" do
    type = :ScenarioOutlineLine
    token = %Gherkin.Token{line: %Gherkin.GherkinLine{text: "Scenario Outline:"}}

    expected_output = %Gherkin.Token{
      line: %Gherkin.GherkinLine{text: "Scenario Outline:"},
      matched_type: type,
      matched_text: "",
      matched_keyword: "Scenario Outline"
    }

    assert Gherkin.TokenMatcher.match_scenario_outline_line(token) == expected_output
  end

  test ".match_scenario_outline_line\\2 updates the token when the token matches in another language" do
    lang  = "it"
    type  = :ScenarioOutlineLine
    token = %Gherkin.Token{matched_type: type, matched_gherkin_dialect: lang, line: %Gherkin.GherkinLine{text: "Schema dello scenario:"}}

    expected_output = %Gherkin.Token{
      matched_type: type,
      line: %Gherkin.GherkinLine{text: "Schema dello scenario:"},
      matched_text: "",
      matched_keyword: "Schema dello scenario",
      matched_gherkin_dialect: lang
    }

    assert Gherkin.TokenMatcher.match_scenario_outline_line(token, lang) == expected_output
  end

  test ".match_background_line\\2 returns false when the token doesn't match" do
    type  = :BackgroundLine
    token = %Gherkin.Token{matched_type: type, line: %Gherkin.GherkinLine{text: "Foo: bar baz"}}

    assert Gherkin.TokenMatcher.match_background_line(token) == false
  end

  test ".match_background_line\\2 updates the token when the token matches" do
    type  = :BackgroundLine
    token = %Gherkin.Token{matched_type: type, line: %Gherkin.GherkinLine{text: "Background:"}}

    expected_output = %Gherkin.Token{
      matched_type: type,
      line: %Gherkin.GherkinLine{text: "Background:"},
      matched_text: "",
      matched_keyword: "Background"
    }

    assert Gherkin.TokenMatcher.match_background_line(token) == expected_output
  end

  test ".match_background_line\\2 updates the token when the token matches in another language" do
    lang  = "it"
    type  = :BackgroundLine
    token = %Gherkin.Token{matched_type: type, matched_gherkin_dialect: lang, line: %Gherkin.GherkinLine{text: "Contesto:"}}

    expected_output = %Gherkin.Token{
      matched_type: type,
      line: %Gherkin.GherkinLine{text: "Contesto:"},
      matched_text: "",
      matched_keyword: "Contesto",
      matched_gherkin_dialect: lang
    }

    assert Gherkin.TokenMatcher.match_background_line(token, lang) == expected_output
  end

  test ".match_examples_line\\2 returns false when the token doesn't match" do
    type  = :ExamplesLine
    token = %Gherkin.Token{matched_type: type, line: %Gherkin.GherkinLine{text: "Foo: bar baz"}}

    assert Gherkin.TokenMatcher.match_examples_line(token) == false
  end

  test ".match_examples_line\\2 updates the token when the token matches" do
    type  = :ExamplesLine
    token = %Gherkin.Token{matched_type: type, line: %Gherkin.GherkinLine{text: "Examples:"}}

    expected_output = %Gherkin.Token{
      matched_type: type,
      line: %Gherkin.GherkinLine{text: "Examples:"},
      matched_text: "",
      matched_keyword: "Examples"
    }

    assert Gherkin.TokenMatcher.match_examples_line(token) == expected_output
  end

  test ".match_examples_line\\2 updates the token when the token matches in another language" do
    lang  = "it"
    type  = :ExamplesLine
    token = %Gherkin.Token{matched_type: type, matched_gherkin_dialect: lang, line: %Gherkin.GherkinLine{text: "Esempi:"}}

    expected_output = %Gherkin.Token{
      matched_type: type,
      line: %Gherkin.GherkinLine{text: "Esempi:"},
      matched_text: "",
      matched_keyword: "Esempi",
      matched_gherkin_dialect: lang
    }

    assert Gherkin.TokenMatcher.match_examples_line(token, lang) == expected_output
  end

  test ".match_table_row\\1 returns false when the line doesn't match" do
    token = %Gherkin.Token{line: %Gherkin.GherkinLine{text: "Foo"}}

    assert Gherkin.TokenMatcher.match_table_row(token) == false
  end

  test ".match_table_row\\1 updates the token when the line matches" do
    token = %Gherkin.Token{
      line: %Gherkin.GherkinLine{
        text: "| Foo | Bar |"
      },
      location: %{column: 5, line: 13},
      matched_items: [
        %Gherkin.Token{
          matched_type: :TableCell,
          matched_text: "Foo",
          location: %{column: 7, line: 13}
        },
        %Gherkin.Token{
          matched_type: :TableCell,
          matched_text: "Bar",
          location: %{column: 13, line: 13}
        }
      ]
    }

    expected_output = %{token |
      matched_type: :TableRow,
      matched_items: [
        %{type: :TableCell, location: %{column: 7, line: 13}, value: "Foo"},
        %{type: :TableCell, location: %{column: 13, line: 13}, value: "Bar"}
      ]
    }

    assert Gherkin.TokenMatcher.match_table_row(token) == expected_output
  end

  test ".match_empty\\1 returns false when the line is not empty" do
    token = %Gherkin.Token{matched_type: :Empty, line: %Gherkin.GherkinLine{text: "Foo"}}

    assert Gherkin.TokenMatcher.match_empty(token) == false
  end

  test ".match_empty\\1 updates the token when the line is empty" do
    token = %Gherkin.Token{
      line: %Gherkin.GherkinLine{text: "  "}
    }

    expected_output = %{
      token |
      matched_type: :Empty,
      matched_indent: 0
    }

    assert Gherkin.TokenMatcher.match_empty(token) == expected_output
  end

  test ".match_comment\\1 returns false when the line is not a comment" do
    token = %Gherkin.Token{line: %Gherkin.GherkinLine{text: "    Given I am a user"}}

    assert Gherkin.TokenMatcher.match_comment(token) == false
  end

  test ".match_comment\\1 updates the token when the line is a comment" do
    token = %Gherkin.Token{line: %Gherkin.GherkinLine{text: "    # This is a comment"}}

    expected_output = %{
      token |
      matched_text: "    # This is a comment",
      matched_type: :Comment,
      matched_indent: 0
    }

    assert Gherkin.TokenMatcher.match_comment(token) == expected_output
  end

  test ".match_language\\1 returns false when the token isn't a language header" do
    token = %Gherkin.Token{line: %Gherkin.GherkinLine{text: "   # This is a comment"}}

    assert Gherkin.TokenMatcher.match_language(token) == false
  end

  test ".match_language\\1 updates the token when the token is a language header" do
    token = %Gherkin.Token{line: %Gherkin.GherkinLine{text: "# language: ja"}}

    expected_output = %{
      token |
      matched_type: :Language,
      matched_text: "ja"
    }

    assert Gherkin.TokenMatcher.match_language(token) == expected_output
  end

  test ".match_doc_string_separator\\2 returns true when anything matches" do
    token1 = %Gherkin.Token{line: %Gherkin.GherkinLine{text: "\"\"\""}}
    token2 = %Gherkin.Token{line: %Gherkin.GherkinLine{text: "```"}}

    expected_output1 = %{
      token1 | 
      matched_text: "\"\"\"",
      matched_type: :DocStringSeparator
    }

    expected_output2 = %{
      token2 |
      matched_text: "```",
      matched_type: :DocStringSeparator
    }

    assert Gherkin.TokenMatcher.match_doc_string_separator(token1) == expected_output1
    assert Gherkin.TokenMatcher.match_doc_string_separator(token2) == expected_output2
  end

  test ".match_doc_string_separator\\2 returns false when the line is not a docstring separator" do
    token = %Gherkin.Token{matched_type: :DocStringSeparator, line: %Gherkin.GherkinLine{text: "foo"}}

    assert Gherkin.TokenMatcher.match_doc_string_separator(token, "\"\"\"") == false
    assert Gherkin.TokenMatcher.match_doc_string_separator(token, "```") == false
  end

  test ".match_doc_string_separator\\2 returns false when the line is the wrong docstring separator" do
    token1 = %Gherkin.Token{matched_type: :DocStringSeparator, line: %Gherkin.GherkinLine{text: "\"\"\""}}
    token2 = %Gherkin.Token{matched_type: :DocStringSeparator, line: %Gherkin.GherkinLine{text: "```"}}

    assert Gherkin.TokenMatcher.match_doc_string_separator(token1, "```") == false
    assert Gherkin.TokenMatcher.match_doc_string_separator(token2, "\"\"\"") == false
  end

  test ".match_doc_string_separator\\2 updates the token when the line matches" do
    token = %Gherkin.Token{line: %Gherkin.GherkinLine{text: "    \"\"\""}}

    expected_output = %Gherkin.Token{
      matched_type: :DocStringSeparator,
      matched_text: "\"\"\"",
      line: %Gherkin.GherkinLine{text: "    \"\"\""}
    }

    assert Gherkin.TokenMatcher.match_doc_string_separator(token, "\"\"\"") == expected_output
  end

  test ".match_eof\\1 returns false when the token is not an EOF" do
    token = %Gherkin.Token{line: %Gherkin.GherkinLine{}}

    assert Gherkin.TokenMatcher.match_eof(token) == false
  end

  test ".match_eof\\1 updates the token when the token is an EOF" do
    token = %Gherkin.Token{matched_type: :Feature}

    expected_output = %Gherkin.Token{matched_type: :EOF}

    assert Gherkin.TokenMatcher.match_eof(token) == expected_output
  end

  test ".match_other\\1 updates the token" do
    token = %Gherkin.Token{matched_type: :ScenarioLine, line: %Gherkin.GherkinLine{text: "Foobar"}}

    expected_output = %{
      token |
      matched_type: :Other,
      matched_text: "Foobar",
      matched_keyword: nil,
      matched_indent: 0
    }

    assert Gherkin.TokenMatcher.match_other(token) == expected_output
  end

  test ".match_step_line\\2 returns false if no keyword matches" do
    token = %Gherkin.Token{
      matched_type: :StepLine,
      line: %Gherkin.GherkinLine{text: "No keywords here"}
    }

    assert Gherkin.TokenMatcher.match_step_line(token) == false
  end

  test ".match_step_line\\2 updates the token if a keyword matches" do
    token = %Gherkin.Token{
      matched_type: :FeatureHeader,
      line: %Gherkin.GherkinLine{text: "Quando clicco su 'Login'"}
    }

    expected_output = %{
      token |
      matched_type: :StepLine,
      matched_keyword: "Quando ",
      matched_text: "clicco su 'Login'",
      matched_gherkin_dialect: "it"
    }

    assert Gherkin.TokenMatcher.match_step_line(token, "it") == expected_output
  end

  test ".match_title_line\\3 when the line doesn't match returns false" do
    type     = :Step
    token    = %Gherkin.Token{matched_type: type, line: %Gherkin.GherkinLine{text: "Foo bar baz"}}
    keywords = ["Given", "When", "Then"]

    assert Gherkin.TokenMatcher.match_title_line(token, type, keywords) == false
  end

  test ".match_title_line\\3 when the line matches updates the token" do
    type     = :Step
    token    = %Gherkin.Token{matched_type: type, line: %Gherkin.GherkinLine{text: "Foo: bar baz"}}
    keywords = ["Foo"]

    expected_output = %Gherkin.Token{
      line: %Gherkin.GherkinLine{text: "Foo: bar baz"},
      matched_type: type,
      matched_keyword: "Foo",
      matched_text: "bar baz"
    }

    assert Gherkin.TokenMatcher.match_title_line(token, type, keywords) == expected_output
  end
end