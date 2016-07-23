defmodule GherkinAstNodeTest do 
  use ExUnit.Case
  doctest Gherkin.AstNode

  test ".add adds a child node" do 
    node  = %{sub_items: %{}, rule_type: :FeatureHeader}
    child = %{
      :FeatureLine => %{}
    }

    assert Gherkin.AstNode.add(node, child) == %{sub_items: child, rule_type: :FeatureHeader}
  end

  test ".get_single returns the correct child" do 
    node = %{sub_items: %{:FeatureLine => %{:foo => "bar"}, :ScenarioHeader => %{"bar" => "baz"}}, rule_type: :FeatureHeader}

    assert Gherkin.AstNode.get_single(node, :ScenarioHeader) == %{"bar" => "baz"}
  end
end