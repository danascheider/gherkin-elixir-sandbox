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

  test ".starts_with? returns true when starts with keyword" do 
    line = %Gherkin.GherkinLine{text: "  Scenario: Foo bar\n", line_number: 3}

    assert Gherkin.GherkinLine.starts_with?(line, "Scenario") == true
  end

  test ".starts_with? returns false when does not start with keyword" do 
    line = %Gherkin.GherkinLine{text: "  Scenario: Foo bar\n", line_number: 3}

    assert Gherkin.GherkinLine.starts_with?(line, "Feature") == false
  end

  test ".starts_with_title_keyword? returns true" do 
    line = %Gherkin.GherkinLine{text: "  Scenario: Foo bar\n", line_number: 3}

    assert Gherkin.GherkinLine.starts_with_title_keyword?(line, "Scenario") == true
  end

  test ".starts_with_title_keyword? returns false" do 
    line = %Gherkin.GherkinLine{text: "  Scenario foo bar\n", line_number: 3}

    assert Gherkin.GherkinLine.starts_with_title_keyword?(line, "Scenario") == false
  end

  test ".get_rest_stripped returns stripped string" do 
    line = %Gherkin.GherkinLine{text: "  Scenario: Foo bar\n", line_number: 3}

    assert Gherkin.GherkinLine.get_rest_stripped(line, 9) == "Foo bar"
  end

  test ".get_rest_stripped shortens string the prescribed amount" do 
    line = %Gherkin.GherkinLine{text: "  Scenario: Foo bar\n", line_number: 3}

    assert Gherkin.GherkinLine.get_rest_stripped(line, 2) == "enario: Foo bar"
  end
end