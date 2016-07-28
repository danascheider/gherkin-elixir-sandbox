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

  test ".get_rest_trimmed\\2 returns stripped string" do 
    line = %Gherkin.GherkinLine{text: "  Scenario: Foo bar\n", line_number: 3}

    assert Gherkin.GherkinLine.get_rest_trimmed(line, 9) == "Foo bar"
  end

  test ".get_rest_trimmed\\2 shortens string the prescribed amount" do 
    line = %Gherkin.GherkinLine{text: "  Scenario: Foo bar\n", line_number: 3}

    assert Gherkin.GherkinLine.get_rest_trimmed(line, 2) == "enario: Foo bar"
  end

  test ".empty?\\1 returns true when empty" do 
    line = %Gherkin.GherkinLine{text: "  \n", line_number: 3}

    assert Gherkin.GherkinLine.empty?(line) == true
  end

  test ".empty?\\1 returns false when not empty" do 
    line = %Gherkin.GherkinLine{text: "  Scenario foo bar\n", line_number: 3}

    assert Gherkin.GherkinLine.empty?(line) == false
  end

  test ".get_line_text\\2 returns the string when the indent is less than 0" do 
    line = %Gherkin.GherkinLine{text: "  Scenario foo bar\n", line_number: 3}

    assert Gherkin.GherkinLine.get_line_text(line, -3) == line.text
  end

  test ".get_line_text\\2 returns the string when the indent is greater than the length" do
    line = %Gherkin.GherkinLine{text: "  Scenario foo bar\n", line_number: 3}

    assert Gherkin.GherkinLine.get_line_text(line, 100) == line.text
  end

  test ".get_line_text\\2 returns the trimmed string" do 
    line = %Gherkin.GherkinLine{text: "  Scenario foo bar\n", line_number: 3}

    assert Gherkin.GherkinLine.get_line_text(line, 1) == " Scenario foo bar\n"
  end
end