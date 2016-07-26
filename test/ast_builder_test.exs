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

  test ".transform_node when rule type is :DocString returns appropriate map" do
    ast_node = %Gherkin.AstNode{
      rule_type: :DocString,
      sub_items: [
        {:DocStringSeparator, %Gherkin.Token{matched_type: :DocString, matched_text: "content_type", location: %{line: 5, column: 9}}},
        {:Other, %Gherkin.Token{line: %Gherkin.GherkinLine{text: "Something"}, matched_text: "Something"}},
        {:Other, %Gherkin.Token{line: %Gherkin.GherkinLine{text: "Something Else"}, matched_text: "Something Else"}}
      ]
    }

    expected_output = %{
      type: :DocString,
      location: %{line: 5, column: 9},
      contentType: "content_type",
      content: "Something\nSomething Else"
    }

    assert Gherkin.AstBuilder.transform_node(ast_node) == expected_output
  end

  test ".transform_node when rule type is :DataTable returns the appropriate map" do
    ast_node = %Gherkin.AstNode{
      rule_type: :DataTable,
      sub_items: [
        {:TableRow, %Gherkin.Token{
          matched_type: :TableRow,
          matched_items: [
            %Gherkin.Token{matched_type: :TableCell, location: %{line: 1, column: 1}}
            ],
          location: %{line: 1, column: 1}
          }
        }
      ]
    }

    expected_output = %{
      type: :DataTable,
      location: %{line: 1, column: 1},
      rows: Gherkin.DataTable.get_table_rows(ast_node)
    }

    assert Gherkin.AstBuilder.transform_node(ast_node) == expected_output
  end

  test ".transform_node when rule type is :Background returns the appropriate map" do
    ast_node = %Gherkin.AstNode{
      rule_type: :Background,
      sub_items: [
        {:BackgroundLine, %Gherkin.Token{matched_type: :BackgroundLine, matched_keyword: "* ", matched_text: "Hello"}},
        {:Step, %Gherkin.Token{matched_type: :Step, matched_keyword: "* ", matched_text: "Foobar"}},
        {:Description, %Gherkin.Token{matched_type: :Description}}
      ]
    }

    expected_output = %{
      type: :Background,
      location: %{column: 1, line: 1},
      keyword: "* ",
      name: "Hello",
      description: %Gherkin.Token{matched_type: :Description},
      steps: [%Gherkin.Token{matched_type: :Step, matched_keyword: "* ", matched_text: "Foobar"}]
    }

    assert Gherkin.AstBuilder.transform_node(ast_node) == expected_output
  end

  test ".transform_node when rule type is :ScenarioDefinition with Scenario returns the appropriate map" do
    tag_node = %Gherkin.AstNode{
      rule_type: :Tags,
      sub_items: [
        {:TagLine, %Gherkin.Token{matched_type: :TagLine, matched_items: [%Gherkin.Token{matched_type: :Tag, location: %{line: 1, column: 14}, matched_text: "Foo bar"}]}}
      ]
    }

    ast_node = %Gherkin.AstNode{
      rule_type: :ScenarioDefinition,
      sub_items: [
        {:Tags, tag_node},
        {:Scenario, %Gherkin.Token{matched_type: :Scenario}}
      ],
    }

    assert Gherkin.AstBuilder.transform_node(ast_node) == [%{type: :Tag, location: %{line: 1, column: 14}, name: "Foo bar"}]
  end
end