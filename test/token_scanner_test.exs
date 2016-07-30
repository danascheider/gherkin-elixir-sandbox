defmodule GherkinTokenScannerTest do
  use ExUnit.Case, async: false
  doctest Gherkin.TokenScanner

  test ".get_lines returns all the lines" do
    body = ~s"""
Feature: Foo bar

  Scenario: Bar baz
    Given neque porro quisquam est
    When quis dolorem ipsum quia dolor sit amet
"""

    expected_output = [
      %Gherkin.GherkinLine{text: "Feature: Foo bar", line_number: 1},
      %Gherkin.GherkinLine{text: "", line_number: 2},
      %Gherkin.GherkinLine{text: "  Scenario: Bar baz", line_number: 3},
      %Gherkin.GherkinLine{text: "    Given neque porro quisquam est", line_number: 4},
      %Gherkin.GherkinLine{text: "    When quis dolorem ipsum quia dolor sit amet", line_number: 5},
      %Gherkin.GherkinLine{text: "", line_number: 6}
    ]

    assert Gherkin.TokenScanner.get_lines(body) == expected_output
  end
end