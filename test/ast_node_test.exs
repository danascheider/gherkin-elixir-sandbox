defmodule GherkinAstNodeTest do 
  use ExUnit.Case
  doctest Gherkin.AstNode

  test ".add adds a child node" do 
    node  = %Gherkin.AstNode{sub_items: [], rule_type: :FeatureHeader}
    child = {:FeatureLine, %Gherkin.Token{}}

    assert Gherkin.AstNode.add(node, child) == %Gherkin.AstNode{sub_items: [ child ], rule_type: :FeatureHeader}
  end

  test ".get_single returns the correct child" do 
    sub_items = [
      {:FeatureLine, %Gherkin.Token{matched_type: :FeatureLine}},
      {:ScenarioHeader, %Gherkin.Token{matched_type: :ScenarioHeader, matched_keyword: "Scenario"}},
      {:ScenarioHeader, %Gherkin.Token{matched_type: :ScenarioHeader, matched_keyword: "Foobar"}}
    ]
    node      = %Gherkin.AstNode{sub_items: sub_items, rule_type: :FeatureHeader}

    assert Gherkin.AstNode.get_single(node, :ScenarioHeader) == %Gherkin.Token{matched_type: :ScenarioHeader, matched_keyword: "Scenario"}
  end

  test ".get_items returns all matching children" do 
    [ first, second, third ] = [
      {:FeatureLine, %Gherkin.Token{matched_type: :FeatureLine}},
      {:ScenarioHeader, %Gherkin.Token{matched_type: :ScenarioHeader, matched_keyword: "Scenario"}},
      {:ScenarioHeader, %Gherkin.Token{matched_type: :ScenarioHeader, matched_keyword: "Foobar"}}
    ]
    node      = %Gherkin.AstNode{sub_items: [first, second, third], rule_type: :FeatureHeader}

    assert Gherkin.AstNode.get_items(node, :ScenarioHeader) == [second, third]
  end

  test ".get_token is the same as .get_single" do
    sub_items = [
      {:FeatureLine, %Gherkin.Token{matched_type: :FeatureLine}},
      {:ScenarioHeader, %Gherkin.Token{matched_type: :ScenarioHeader, matched_keyword: "Scenario"}},
      {:ScenarioHeader, %Gherkin.Token{matched_type: :ScenarioHeader, matched_keyword: "Foobar"}}
    ]
    node      = %Gherkin.AstNode{sub_items: sub_items, rule_type: :FeatureHeader}

    assert Gherkin.AstNode.get_token(node, :ScenarioHeader) == Gherkin.AstNode.get_single(node, :ScenarioHeader)
  end

  test ".get_tokens is the same as .get_items" do 
    sub_items = [
      {:FeatureLine, %Gherkin.Token{matched_type: :FeatureLine}},
      {:ScenarioHeader, %Gherkin.Token{matched_type: :ScenarioHeader, matched_keyword: "Scenario"}},
      {:ScenarioHeader, %Gherkin.Token{matched_type: :ScenarioHeader, matched_keyword: "Foobar"}}
    ]
    node      = %Gherkin.AstNode{sub_items: sub_items, rule_type: :FeatureHeader}

    assert Gherkin.AstNode.get_items(node, :ScenarioHeader) == Gherkin.AstNode.get_tokens(node, :ScenarioHeader)
  end
end