defmodule GherkinLineTest do
  use ExUnit.Case
  doctest Gherkin.GherkinLine

  test ".trimmed_text returns trimmed text" do 
    line = %Gherkin.GherkinLine{text: "  Scenario: Foo bar\n", line_number: 3}

    assert Gherkin.GherkinLine.trimmed_text(line) == "Scenario: Foo bar\n"
  end

  test ".indent returns level of indent" do 
    line = %Gherkin.GherkinLine{text: "  Scenario: Foo bar\n", line_number: 3}

    assert Gherkin.GherkinLine.indent(line) == 2
  end
end