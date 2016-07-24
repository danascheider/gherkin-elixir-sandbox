defmodule GherkinAstNodeTest do 
  use ExUnit.Case
  doctest Gherkin.AstNode

  test ".add adds a child node" do 
    node  = %Gherkin.AstNode{sub_items: [], rule_type: :FeatureHeader}
    child = {:FeatureLine, {}}

    assert Gherkin.AstNode.add(node, child) == %Gherkin.AstNode{sub_items: [ child ], rule_type: :FeatureHeader}
  end

  test ".get_single returns the correct child" do 
    node = %Gherkin.AstNode{sub_items: [{:FeatureLine, %{:foo => "bar"}}, {:ScenarioHeader, %{"bar" => "baz"}}, {:ScenarioHeader, %{"baz" => "qux"}}], rule_type: :FeatureHeader}

    assert Gherkin.AstNode.get_single(node, :ScenarioHeader) == {:ScenarioHeader, %{"bar" => "baz"}}
  end

  test ".get_items returns all matching children" do 
    node = %Gherkin.AstNode{sub_items: [{:FeatureLine, %{:foo => "bar"}}, {:ScenarioHeader, %{"bar" => "baz"}}, {:ScenarioHeader, %{"baz" => "qux"}}], rule_type: :FeatureHeader}

    assert Gherkin.AstNode.get_items(node, :ScenarioHeader) == [{:ScenarioHeader, %{"bar" => "baz"}}, {:ScenarioHeader, %{"baz" => "qux"}}]
  end

  test ".get_token is the same as .get_single" do 
    node = %Gherkin.AstNode{sub_items: [{:FeatureLine, %{:foo => "bar"}}, {:ScenarioHeader, %{"bar" => "baz"}}, {:ScenarioHeader, %{"baz" => "qux"}}], rule_type: :FeatureHeader}

    assert Gherkin.AstNode.get_token(node, :ScenarioHeader) == Gherkin.AstNode.get_single(node, :ScenarioHeader)
  end

  test ".get_tokens is the same as .get_items" do 
    node = %Gherkin.AstNode{sub_items: [{:FeatureLine, %{:foo => "bar"}}, {:ScenarioHeader, %{"bar" => "baz"}}, {:ScenarioHeader, %{"baz" => "qux"}}], rule_type: :FeatureHeader}

    assert Gherkin.AstNode.get_tokens(node, :ScenarioHeader) == Gherkin.AstNode.get_items(node, :ScenarioHeader)
  end
end