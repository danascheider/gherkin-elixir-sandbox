defmodule GherkinAstNodeTest do
  use ExUnit.Case
  doctest Gherkin.AstNode

  test "#add\\3 adds object to sub-items" do
    object          = %{foo: :bar}

    expected_output = %Gherkin.AstNode{
      sub_items: %{
        :None => [%{foo: :bar}]
      }
    }

    assert Gherkin.AstNode.add(%Gherkin.AstNode{}, :None, object)
  end

  test "#get_items\\2 retrieves sub-items if they exist" do
    ast_node = %Gherkin.AstNode{sub_items: %{:GherkinDocument => [%Gherkin.AstNode{rule_type: :GherkinDocument}]}}

    assert Gherkin.AstNode.get_items(ast_node, :GherkinDocument) == [%Gherkin.AstNode{rule_type: :GherkinDocument}]
  end

  test "#get_items\\2 returns an empty list if no sub-items exist" do
    ast_node = %Gherkin.AstNode{}

    assert Gherkin.AstNode.get_items(ast_node, :GherkinDocument) == []
  end

  test "#get_single\/2 returns nil if no matching sub-items exist" do
    ast_node = %Gherkin.AstNode{}

    assert Gherkin.AstNode.get_single(ast_node, :GherkinDocument) == nil
  end
end