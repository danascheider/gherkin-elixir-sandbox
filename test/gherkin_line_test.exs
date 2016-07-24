defmodule GherkinLineTest do
  use ExUnit.Case
  doctest Gherkin.GherkinLine

  test ".line_text returns full line text" do 
    line = %Gherkin.GherkinLine{text: "  Scenario: Foo bar\n", line_number: 3}

    assert Gherkin.GherkinLine.line_text(line) == "  Scenario: Foo bar\n"
  end

  test ".trimmed_text returns trimmed text" do 
    line = %Gherkin.GherkinLine{text: "  Scenario: Foo bar\n", line_number: 3}

    assert Gherkin.GherkinLine.trimmed_text(line) == "Scenario: Foo bar\n"
  end
end