defmodule GherkinAstBuilderTest do
  use ExUnit.Case
  doctest Gherkin.AstBuilder

  test ".reset/0 returns a reset stack" do
    expected_output = %{
      stack: [%Gherkin.AstNode{rule_type: :None}],
      comments: []
    }
    
    assert Gherkin.AstBuilder.reset == expected_output
  end
end