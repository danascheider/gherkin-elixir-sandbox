defmodule GherkinAstNodeTest do
  use ExUnit.Case
  doctest Gherkin.AstNode

  test "#add/3 adds object to sub-items" do
    object          = %{foo: :bar}

    expected_output = %Gherkin.AstNode{
      sub_items: %{
        :None => [%{foo: :bar}]
      }
    }

    assert Gherkin.AstNode.add(%Gherkin.AstNode{}, :None, object) == expected_output
  end

  test "#get_items/2 retrieves sub-items if they exist" do
    ast_node = %Gherkin.AstNode{sub_items: %{:GherkinDocument => [%Gherkin.AstNode{rule_type: :GherkinDocument}]}}

    assert Gherkin.AstNode.get_items(ast_node, :GherkinDocument) == [%Gherkin.AstNode{rule_type: :GherkinDocument}]
  end

  test "#get_items/2 returns an empty list if no sub-items exist" do
    ast_node = %Gherkin.AstNode{}

    assert Gherkin.AstNode.get_items(ast_node, :GherkinDocument) == []
  end

  test "#get_single/2 returns nil if no matching sub-items exist" do
    ast_node = %Gherkin.AstNode{}

    assert Gherkin.AstNode.get_single(ast_node, :GherkinDocument) == nil
  end

  test "#get_tags/1 returns tags" do
    ast_node = %Gherkin.AstNode{
      rule_type: :GherkinDocument,
      sub_items: %{
        :Tags => [
          %Gherkin.AstNode{
            rule_type: :Tags,
            sub_items: %{
              :TagLine => [
                %Gherkin.Token{
                  matched_type: :TagLine,
                  location: %{line: 3, column: 3},
                  matched_items: [
                    %Gherkin.Tag{text: "@foo", column: 3},
                    %Gherkin.Tag{text: "@bar", column: 8}
                  ]
                }
              ]
            }
          }
        ]
      }
    }

    expected_output = [
      %{type: :Tag, location: %{line: 3, column: 3}, text: "@foo"},
      %{type: :Tag, location: %{line: 3, column: 8}, text: "@bar"}
    ]

    assert Gherkin.AstNode.get_tags(ast_node) == expected_output
  end

  test "#get_tags/1 returns an empty list when there are no tags" do
    ast_node = %Gherkin.AstNode{
      rule_type: :GherkinDocument,
      sub_items: %{}
    }

    assert Gherkin.AstNode.get_tags(ast_node) == []
  end
end