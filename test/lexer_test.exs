defmodule GherkinLexerTest do 
  use ExUnit.Case

  doctest Gherkin.Lexer

  test "tokenizes a simple feature" do 
    text = "Feature: Test"

    assert Gherkin.Lexer.tokenize(text) == %Gherkin.Lexer{line: 1, location: %{line: 1}}
  end
end