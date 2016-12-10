defmodule GherkinParserTest do
  use ExUnit.Case
  doctest Gherkin.Parser

  test ".parse\\2 creates a trivial AST" do
    input           = nil

    expected_output = %{
      type: :GherkinDocument,
      comments: []
    }

    assert Gherkin.Parser.parse(input, "feature.feature") == expected_output
  end

  test ".parse\\2 creates an AST" do
    input           = "Feature: See if this works"

    expected_output = %{
      type: :GherkinDocument,
      feature: %{
        tags: [],
        location: %{line: 1, column: 1},
        language: "en",
        keyword: "Feature",
        name: "See if this works",
        children: []
      },
      comments: []
    }

    assert Gherkin.Parser.parse(input, "feature.feature") == expected_output
  end
end