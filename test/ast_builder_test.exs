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
    context = %Gherkin.ParserContext{stack: stack}
    output  = %{context |
      stack: [
        %Gherkin.AstNode{rule_type: :None},
        %Gherkin.AstNode{rule_type: :Foobar}
      ]
    }

    assert Gherkin.AstBuilder.start_rule(context, :Foobar) == output
  end

  # test ".end_rule/1 builds the final node" do
  #   stack  = [
  #     %Gherkin.AstNode{rule_type: :None}, 
  #     %Gherkin.AstNode{
  #       rule_type: :Step,
  #       sub_items: %{
  #         :StepLine => [%Gherkin.Token{matched_type: :StepLine}]
  #       }
  #     }
  #   ]

  #   context = %Gherkin.ParserContext{stack: stack}

  #   output = %{context |
  #     stack: [
  #       %Gherkin.AstNode{
  #         rule_type: :None, 
  #         sub_items: %{
  #           :Step => [
  #             %{
  #               argument: nil, 
  #               keyword: nil, 
  #               location: %{column: 1, line: 1}, 
  #               text: nil, 
  #               type: :Step
  #             }
  #           ]
  #         }
  #       }
  #     ]
  #   }

  #   assert Gherkin.AstBuilder.end_rule(context) == output
  # end

  test ".current_node/1 returns the last node in the stack" do
    stack = [
      %Gherkin.AstNode{rule_type: :None},
      %Gherkin.AstNode{rule_type: :GherkinDocument}
    ]

    assert Gherkin.AstBuilder.current_node(stack) == %Gherkin.AstNode{rule_type: :GherkinDocument}
  end

  test ".build/2 builds the tree" do
    stack   = [
      %Gherkin.AstNode{}
    ]

    token   = %Gherkin.Token{matched_type: :FeatureLine}
    context = %Gherkin.ParserContext{stack: stack}

    assert Gherkin.AstBuilder.build(context, token) == {[%Gherkin.AstNode{sub_items: %{:FeatureLine => [token]}}], []}
  end

  test ".build/2 adds comment token to the comments" do
    input = %Gherkin.ParserContext{stack: [%Gherkin.AstNode{}]}
    token = %Gherkin.Token{matched_type: :Comment, location: %{line: 2, column: 3}, matched_text: "This is a comment"}

    modified_token = %{type: :Comment, location: %{line: 2, column: 3}, text: "This is a comment"}

    assert Gherkin.AstBuilder.build(input, token) == {[%Gherkin.AstNode{}], [modified_token]}
  end

  test ".transform_node/2 when the rule type is :Step transforms the node" do
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

  test ".transform_node/2 when the rule type is :DocString transforms the node" do
    ast_node = %Gherkin.AstNode{
      rule_type: :DocString,
      sub_items: %{
        :DocStringSeparator => [
          %Gherkin.Token{matched_type: :DocStringSeparator, matched_keyword: "\"\"\"", matched_text: "json", location: %{line: 4, column: 6}},
          %Gherkin.Token{matched_type: :DocStringSeparator, matched_keyword: "\`\`\`"}
        ],
        :Other => [
          %Gherkin.Token{matched_type: :Other, matched_text: "Foo"},
          %Gherkin.Token{matched_type: :Other, matched_text: "Bar"}
        ]
      }
    }

    expected_output = %{
      type: :DocString,
      location: %{line: 4, column: 6},
      content_type: "json",
      content: "Foo\nBar"
    }

    assert Gherkin.AstBuilder.transform_node(ast_node) == expected_output
  end

  test ".transform_node/2 when the rule type is :Background transforms the node" do
    ast_node      = %Gherkin.AstNode{
      rule_type: :Background,
      sub_items: %{
        :BackgroundLine => [
          %Gherkin.Token{
            matched_type: :BackgroundLine, 
            location: %{line: 3, column: 7}, 
            matched_keyword: "Background",
            matched_text: "Foobar"
          }
        ],
        :Description => [
          %Gherkin.Token{matched_type: :Description, matched_text: "Hello world"}
        ],
        :Step => [
          %Gherkin.Token{matched_type: :Step},
          %Gherkin.Token{matched_type: :Step}
        ]
      }
    }

    expected_output = %{
      type: :Background,
      location: %{line: 3, column: 7},
      keyword: "Background",
      name: "Foobar",
      description: %Gherkin.Token{matched_type: :Description, matched_text: "Hello world"},
      steps: [%Gherkin.Token{matched_type: :Step}, %Gherkin.Token{matched_type: :Step}]
    }

    assert Gherkin.AstBuilder.transform_node(ast_node) == expected_output
  end

  test ".transform_node/2 when the rule type is :ScenarioDefinition with scenario transforms the node" do
    ast_node      = %Gherkin.AstNode{
      rule_type: :ScenarioDefinition,
      sub_items: %{
        :Tags => [
          %Gherkin.AstNode{
            rule_type: :Tags,
            sub_items: %{
              :TagLine => [
                %Gherkin.Token{
                  matched_type: :TagLine, 
                  matched_items: [
                    %Gherkin.Tag{text: "@foo", column: 3},
                    %Gherkin.Tag{text: "@bar", column: 8}
                  ],
                  location: %{line: 5, column: 3}
                }
              ]
            }
          }
        ],
        :Scenario => [
          %Gherkin.AstNode{
            rule_type: :Scenario,
            sub_items: %{
              :ScenarioLine => [
                %Gherkin.Token{
                  matched_type: :ScenarioLine,
                  matched_keyword: "Scenario",
                  matched_text: "Foobar",
                  location: %{line: 6, column: 3}
                }
              ],
              :Description => [
                %Gherkin.Token{matched_type: :Description, location: %{line: 7, column: 5}}
              ],
              :Step => [
                %Gherkin.Token{
                  matched_type: :Step,
                  matched_keyword: "Given ",
                  matched_text: "I am a user",
                  location: %{line: 9, column: 5}
                }
              ]
            }
          }
        ]
      }
    }

    expected_output = %{
      type: :Scenario,
      tags: [
        %{type: :Tag, text: "@foo", location: %{line: 5, column: 3}},
        %{type: :Tag, text: "@bar", location: %{line: 5, column: 8}}
      ],
      location: %{line: 6, column: 3},
      keyword: "Scenario",
      name: "Foobar",
      description: %Gherkin.Token{matched_type: :Description, location: %{line: 7, column: 5}},
      steps: [
        %Gherkin.Token{
          matched_type: :Step,
          matched_keyword: "Given ",
          matched_text: "I am a user",
          location: %{line: 9, column: 5}
        }
      ]
    }

    assert Gherkin.AstBuilder.transform_node(ast_node) == expected_output
  end

  test ".transform_node/2 when the rule type is :GherkinDocument transforms the node" do
    ast_node      = %Gherkin.AstNode{
      rule_type: :GherkinDocument,
      sub_items: %{
        :Feature => [%Gherkin.Token{matched_type: :Feature}]
      }
    }

    expected_output = %{
      type: :GherkinDocument,
      feature: %Gherkin.Token{matched_type: :Feature},
      comments: []
    }

    assert Gherkin.AstBuilder.transform_node(ast_node) == expected_output
  end
end