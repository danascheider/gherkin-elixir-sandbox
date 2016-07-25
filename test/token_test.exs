defmodule GherkinTokenTest do 
  use ExUnit.Case
  doctest Gherkin.Token

  test ".eof? returns true if line is nil" do 
    token = %Gherkin.Token{line: nil}

    assert Gherkin.Token.eof?(token) == true
  end

  test ".eof? returns false if line is defined" do 
    line  = %Gherkin.GherkinLine{text: "  Scenario: Foo bar"}
    token = %Gherkin.Token{line: line}

    assert Gherkin.Token.eof?(token) == false
  end

  test ".token_value returns 'EOF' if EOF" do 
    token = %Gherkin.Token{line: nil}

    assert Gherkin.Token.token_value(token) == "EOF"
  end

  test ".token_value returns the line text" do 
    line  = %Gherkin.GherkinLine{text: "  Scenario: Foo bar"}
    token = %Gherkin.Token{line: line}

    assert Gherkin.Token.token_value(token) == "  Scenario: Foo bar"
  end

  test ".get_location\\1 returns the location map" do 
    line  = %Gherkin.GherkinLine{text: "  Scenario: Foo bar"}
    token = %Gherkin.Token{line: line, location: %{line: 3, column: 3}}

    assert Gherkin.Token.get_location(token) == %{line: 3, column: 3}
  end

  test ".get_location\\2 returns the location with a given column" do 
    line  = %Gherkin.GherkinLine{text: "  Scenario: Foo bar"}
    token = %Gherkin.Token{line: line, location: %{line: 3, column: 1}}

    assert Gherkin.Token.get_location(token, 3) == %{line: 3, column: 3}
  end
end