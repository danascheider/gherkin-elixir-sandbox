defmodule GherkinAstBuilderTest do 
  use ExUnit.Case
  doctest Gherkin.AstBuilder 

  test ".start_rule returns an AST node" do 
    ast_node = %Gherkin.AstNode{rule_type: :FeatureHeader, sub_items: []}

    assert Gherkin.AstBuilder.start_rule([], :FeatureHeader) == [ast_node]
  end

  test ".transform_node when rule type is :Step returns appropriate map" do 
    ast_node = %Gherkin.AstNode{
      rule_type: :Step, 
      sub_items: [
        {:StepLine, %Gherkin.Token{matched_type: :StepLine, matched_keyword: "* ", matched_text: "Foo bar", location: %{line: 3, column: 3}}},
        {:FeatureLine, %Gherkin.Token{matched_type: :FeatureLine}}
      ]
    }

    expected_output = %{
      type: :Step, 
      location: %{line: 3, column: 3},
      keyword: "* ",
      text: "Foo bar",
      arguments: nil
    }

    assert Gherkin.AstBuilder.transform_node(ast_node) == expected_output
  end
end