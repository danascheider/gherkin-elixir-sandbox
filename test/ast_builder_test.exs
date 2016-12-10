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

  test ".transform_node//1 when the rule type is :Step transforms the node" do
    ast_node = %Gherkin.AstNode{
      rule_type: :Step,
      sub_items: %{
        :StepLine => [
          %Gherkin.Token{
            matched_type: :StepLine, 
            matched_keyword: "Given ",
            matched_text: "I am the walrus",
            location: %{line: 3, column: 4}}
        ],
        :DocString => [
          %Gherkin.Token{
            matched_type: :DocString,
            matched_text: "foo bar baz"
          }
        ]
      }
    }

    expected_output = %{
      type: :Step,
      location: %{line: 3, column: 4},
      keyword: "Given ",
      text: "I am the walrus",
      argument: %Gherkin.Token{matched_type: :DocString, matched_text: "foo bar baz"}
    }

    assert Gherkin.AstBuilder.transform_node(ast_node) == expected_output
  end
end