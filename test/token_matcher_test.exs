ExUnit.configure exclude: :pending, trace: true

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

  test ".match_feature_line\\2 returns true when the line matches" do
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

  test ".match_feature_line\\2 returns true when the line matches in another language" do
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

  test ".match_scenario_line\\2 returns false when the token doesn't match" do
    type  = :ScenarioLine
    token = %Gherkin.Token{matched_type: type, line: %Gherkin.GherkinLine{text: "Foo bar baz"}}

    assert Gherkin.TokenMatcher.match_scenario_line(token) == false
  end

  test ".match_scenario_line\\2 returns true when the token matches" do
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

  test ".match_scenario_line\\2 returns true when the token matches in another language" do
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

  test ".match_background_line\\2 returns true when the token matches in another language" do
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

  test ".match_examples_line\\2 returns true when the token matches" do
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

  test ".match_examples_line\\2 returns true when the token matches in another language" do
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