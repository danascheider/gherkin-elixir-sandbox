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

  test ".start_rule/2 adds a node to the stack" do
    stack   = [%Gherkin.AstNode{rule_type: :None}]
    output  = [
      %Gherkin.AstNode{rule_type: :None},
      %Gherkin.AstNode{rule_type: :Foobar}
    ]

    assert Gherkin.AstBuilder.start_rule(stack, :Foobar) == output
  end

  test ".current_node//1 returns the last node in the stack" do
    stack = [
      %Gherkin.AstNode{rule_type: :None},
      %Gherkin.AstNode{rule_type: :GherkinDocument}
    ]

    assert Gherkin.AstBuilder.current_node(stack) == %Gherkin.AstNode{rule_type: :GherkinDocument}
  end
end