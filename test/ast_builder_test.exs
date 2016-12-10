defmodule GherkinAstBuilderTest do
  use ExUnit.Case
  doctest Gherkin.AstBuilder

  test ".reset/0 returns a reset stack" do
    assert Gherkin.AstBuilder.reset == [%Gherkin.AstNode{rule_type: :None}]
  end
end