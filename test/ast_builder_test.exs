defmodule GherkinAstBuilderTest do 
  use ExUnit.Case
  doctest Gherkin.AstBuilder 

  test ".start_rule\\2 returns an AST node" do 
    ast_node = %Gherkin.AstNode{rule_type: :FeatureHeader, sub_items: []}

    assert Gherkin.AstBuilder.start_rule([], :FeatureHeader) == [ast_node]
  end

  test ".current_node\\1 returns the last item in the stack" do
    stack = [%Gherkin.AstNode{rule_type: :Feature}, %Gherkin.AstNode{rule_type: :FeatureHeader}]

    assert Gherkin.AstBuilder.current_node(stack) == %Gherkin.AstNode{rule_type: :FeatureHeader}
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
        {:Scenario, %Gherkin.AstNode{
          rule_type: :Scenario, sub_items: [
            {:ScenarioLine, %Gherkin.Token{matched_type: :ScenarioLine, location: %{line: 2, column: 3}, matched_keyword: "* ", matched_text: "Foo bar"}},
            {:Description, %Gherkin.Token{matched_type: :Description}},
            {:Step, %Gherkin.Token{matched_type: :Step}},
            {:Step, %Gherkin.Token{matched_type: :Step}}
          ]
        }}
      ]
    }

    tags = [%{type: :Tag, location: %{line: 1, column: 14}, name: "Foo bar"}]

    expected_output = %{
      type: :ScenarioDefinition,
      tags: tags,
      location: %{line: 2, column: 3},
      keyword: "* ",
      name: "Foo bar",
      steps: [%Gherkin.Token{matched_type: :Step}, %Gherkin.Token{matched_type: :Step}],
      description: %Gherkin.Token{matched_type: :Description}
    }

    assert Gherkin.AstBuilder.transform_node(ast_node) == expected_output
  end

  test ".transform_node when rule type is :ScenarioDefinition with ScenarioOutline returns the appropriate map" do
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
        {:ScenarioOutline, %Gherkin.AstNode{
          rule_type: :ScenarioOutline, 
          sub_items: [
              {:Description, %Gherkin.Token{
                  matched_type: :Description
                }
              },
              {:ScenarioOutlineLine, %Gherkin.Token{
                  matched_type: :ScenarioOutlineLine,
                  matched_keyword: "* ",
                  matched_text: "Foobar",
                  location: %{line: 2, column: 14}
                }
              },
              {:Step, %Gherkin.Token{matched_type: :Step}},
              {:ExamplesDefinition, %Gherkin.Token{matched_type: :ExamplesDefinition}}
            ]
          }
        }
      ]
    }

    tags = [%{type: :Tag, location: %{line: 1, column: 14}, name: "Foo bar"}]

    expected_output = %{
      type: :ScenarioOutline,
      tags: tags,
      location: %{line: 2, column: 14},
      keyword: "* ",
      name: "Foobar",
      description: %Gherkin.Token{matched_type: :Description},
      steps: [%Gherkin.Token{matched_type: :Step}],
      examples: [%Gherkin.Token{matched_type: :ExamplesDefinition}]
    }

    assert Gherkin.AstBuilder.transform_node(ast_node) == expected_output
  end

  test ".transform_node\\1 when rule type is :ExamplesDefinition returns the correct map" do
    tag_node = %Gherkin.AstNode{
      rule_type: :Tags,
      sub_items: [
        {:TagLine, %Gherkin.Token{matched_type: :TagLine, matched_items: [%Gherkin.Token{matched_type: :Tag, location: %{line: 1, column: 14}, matched_text: "Foo bar"}]}}
      ]
    }

    table    = %Gherkin.AstNode{
      rule_type: :ExamplesTable,
      sub_items: [
        {:TableRow, %Gherkin.Token{matched_type: :TableRow, matched_items: [%Gherkin.Token{matched_type: :TableCell}]}},
        {:TableRow, %Gherkin.Token{matched_type: :TableRow, matched_items: [%Gherkin.Token{matched_type: :TableCell}]}},
        {:TableRow, %Gherkin.Token{matched_type: :TableRow, matched_items: [%Gherkin.Token{matched_type: :TableCell}]}}
      ]
    }

    ast_node     = %Gherkin.AstNode{
      rule_type: :ExamplesDefinition,
      sub_items: [
        {:Examples, %Gherkin.AstNode{
          rule_type: :Examples, 
          sub_items: [
              {:Tags, tag_node},
              {:ExamplesLine, %Gherkin.Token{matched_type: :ExamplesLine, location: %{line: 13, column: 41}, matched_keyword: "* ", matched_text: "Foo"}},
              {:Description, %Gherkin.Token{matched_type: :Description}},
              {:ExamplesTable, table}
            ]
          }
        }
      ]
    }

    tags = [%{type: :Tag, location: %{line: 1, column: 14}, name: "Foo bar"}]

    expected_output = %{
      type: :Examples,
      tags: tags,
      location: %{line: 13, column: 41},
      keyword: "* ",
      name: "Foo",
      description: %Gherkin.Token{matched_type: :Description},
      table_header: Gherkin.DataTable.get_table_header(table),
      table_body: Gherkin.DataTable.get_table_body(table)
    }

    assert Gherkin.AstBuilder.transform_node(ast_node) == expected_output
  end

  test ".transform_node\\1 when rule type is :ExamplesTable returns the appropriate map" do
    table    = %Gherkin.AstNode{
      rule_type: :ExamplesTable,
      sub_items: [
        {:TableRow, %Gherkin.Token{matched_type: :TableRow, matched_items: [%Gherkin.Token{matched_type: :TableCell}]}},
        {:TableRow, %Gherkin.Token{matched_type: :TableRow, matched_items: [%Gherkin.Token{matched_type: :TableCell}]}},
        {:TableRow, %Gherkin.Token{matched_type: :TableRow, matched_items: [%Gherkin.Token{matched_type: :TableCell}]}}
      ]
    }

    expected_output = %{
      table_header: Gherkin.DataTable.get_table_header(table),
      table_body: Gherkin.DataTable.get_table_body(table)
    }

    assert Gherkin.AstBuilder.transform_node(table) == expected_output
  end

  test ".transform_node\\1 when rule type is :Description returns the description" do
    description = %Gherkin.AstNode{
      rule_type: :Description,
      sub_items: [
        {:Other, %Gherkin.Token{matched_type: :Other, line: %Gherkin.GherkinLine{text: "Foo"}}},
        {:Other, %Gherkin.Token{matched_type: :Other, line: %Gherkin.GherkinLine{text: "Bar"}}},
        {:Other, %Gherkin.Token{matched_type: :Other, line: %Gherkin.GherkinLine{text: ""}}}
      ]
    }

    expected_output = "Foo\nBar"

    assert Gherkin.AstBuilder.transform_node(description) == expected_output
  end

  test ".transform_node\\1 when rule type is :Feature and no header returns nil" do
    ast_node = %Gherkin.AstNode{rule_type: :Feature}

    assert Gherkin.AstBuilder.transform_node(ast_node) == nil
  end

  test ".transform_node\\1 when rule type is :Feature and no feature line returns nil" do
    ast_node = %Gherkin.AstNode{
      rule_type: :Feature,
      sub_items: [{:FeatureHeader, %Gherkin.AstNode{rule_type: :FeatureHeader}}]
    }

    assert Gherkin.AstBuilder.transform_node(ast_node) == nil
  end

  test ".transform_node\\1 when rule type is :Feature returns appropriate map" do
    tag_node = %Gherkin.AstNode{
      rule_type: :Tags,
      sub_items: [
        {:TagLine, %Gherkin.Token{matched_type: :TagLine, matched_items: [%Gherkin.Token{matched_type: :Tag, location: %{line: 1, column: 14}, matched_text: "Foo bar"}]}}
      ]
    }

    ast_node = %Gherkin.AstNode{
      rule_type: :Feature,
      sub_items: [
        {:FeatureHeader, %Gherkin.AstNode{
            rule_type: :FeatureHeader,
            sub_items: [
              {:FeatureLine, %Gherkin.Token{matched_type: :FeatureLine, location: %{column: 1, line: 1}, matched_keyword: "* ", matched_text: "Foo bar"}},
              {:Tags, tag_node},
              {:Description, %Gherkin.Token{matched_type: :Description}},
            ]
          }
        },
        {:Background, %Gherkin.AstNode{rule_type: :Background}},
        {:ScenarioDefinition, %Gherkin.AstNode{rule_type: :ScenarioDefinition}},
        {:ScenarioDefinition, %Gherkin.AstNode{rule_type: :ScenarioDefinition}}
      ]
    }

    tags = [%{type: :Tag, location: %{line: 1, column: 14}, name: "Foo bar"}]

    expected_output = %{
      type: :Feature,
      tags: tags,
      location: %{column: 1, line: 1},
      language: "en",
      keyword: "* ",
      name: "Foo bar",
      description: %Gherkin.Token{matched_type: :Description},
      children: [
        %Gherkin.AstNode{rule_type: :Background},
        %Gherkin.AstNode{rule_type: :ScenarioDefinition},
        %Gherkin.AstNode{rule_type: :ScenarioDefinition}
      ]
    }

    assert Gherkin.AstBuilder.transform_node(ast_node) == expected_output
  end

  test ".transform_node\\1 when rule type is :GherkinDocument returns appropriate map" do
    ast_node = %Gherkin.AstNode{
      rule_type: :GherkinDocument,
      sub_items: [
        {:Feature, %Gherkin.AstNode{rule_type: :Feature}},
        {:Comment, %Gherkin.Token{matched_type: :Comment, location: %{column: 1, line: 3}, matched_text: "This is a comment"}}
      ]
    }

    expected_output = %{
      type: :GherkinDocument,
      feature: %Gherkin.AstNode{rule_type: :Feature},
      comments: [%Gherkin.Token{matched_type: :Comment, location: %{column: 1, line: 3}, matched_text: "This is a comment"}]
    }

    assert Gherkin.AstBuilder.transform_node(ast_node) == expected_output
  end
end