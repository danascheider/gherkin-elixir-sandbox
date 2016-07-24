defmodule GherkinTokenTest do 
  use ExUnit.Case
  doctest Gherkin.Token

  test ".eof? returns true if line is nil" do 
    token = %Gherkin.Token{line: nil}

    assert Gherkin.Token.eof?(token) == true
  end

  test ".eof? returns false if line is defined" do 
    token = %Gherkin.Token{line: 4}

    assert Gherkin.Token.eof?(token) == false
  end
end