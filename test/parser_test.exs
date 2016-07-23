defmodule GherkinTest do
  use ExUnit.Case
  doctest Gherkin

  test "parses a simple feature" do
    feature = "Feature: Test"
    tokens  = Gherkin.Lexer.tokenize(feature)

    assert Gherkin.Parser.parse(tokens) == %{
      feature: %{
        type: :Feature,
        tags: [],
        location: %{line: 1, column: 1},
        language: "en",
        keyword: "Feature",
        name: "Test",
        children: []
      },
      comments: [],
      type: :GherkinDocument
    }
  end
end
