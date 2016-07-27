defmodule Gherkin.AstBuilder do 
  def start_rule(stack, rule_type) do
    Enum.concat(stack, [ %Gherkin.AstNode{rule_type: rule_type} ])
  end

  def end_rule(stack) do
    node_to_add = List.last(stack)
    new_stack   = Enum.take(stack, Enum.count(stack) - 1)

    current_node(new_stack) |> Gherkin.AstNode.add(transform_node(node_to_add))
  end

  def build(token) do
    [
      %{
        type: :Comment,
        location: token.location,
        text: token.matched_text
      }
    ]
  end

  def current_node(stack), do: List.last(stack)

  def transform_node(ast_node = %Gherkin.AstNode{rule_type: :Step}) do
    step_line  = Gherkin.AstNode.get_token(ast_node, :StepLine)
    argument   = Gherkin.AstNode.get_token(ast_node, :DataTable) || Gherkin.AstNode.get_token(ast_node, :DocString) || nil

    %{
      type: ast_node.rule_type,
      location: Gherkin.Token.get_location(step_line),
      keyword: step_line.matched_keyword,
      arguments: argument,
      text: step_line.matched_text
    }
  end

  def transform_node(ast_node = %Gherkin.AstNode{rule_type: :DocString}) do 
    separator_token = Gherkin.AstNode.get_token(ast_node, :DocStringSeparator)
    content_type    = separator_token.matched_text
    line_tokens     = Gherkin.AstNode.get_tokens(ast_node, :Other)
    content         = Enum.map(line_tokens, fn({:Other, t}) -> t.matched_text end) |> Enum.join("\n")

    %{
      type: ast_node.rule_type,
      location: Gherkin.Token.get_location(separator_token),
      content: content,
      contentType: content_type
    }
  end

  def transform_node(ast_node = %Gherkin.AstNode{rule_type: :DataTable}) do
    rows = Gherkin.DataTable.get_table_rows(ast_node)

    %{
      type: ast_node.rule_type,
      location: List.first(rows).location,
      rows: rows
    }
  end

  def transform_node(ast_node = %Gherkin.AstNode{rule_type: :Background}) do
    background_line = Gherkin.AstNode.get_token(ast_node, :BackgroundLine)
    description     = Gherkin.AstNode.get_single(ast_node, :Description)
    steps                = Gherkin.AstNode.get_tokens(ast_node, :Step)
                             |> Enum.map(fn({_, step}) -> step end)

    %{
      type: ast_node.rule_type,
      location: background_line.location,
      keyword: background_line.matched_keyword,
      name: background_line.matched_text,
      description: description,
      steps: steps
    }
  end

  def transform_node(ast_node = %Gherkin.AstNode{rule_type: :ScenarioDefinition}) do
    tags = get_tags(ast_node)

    if Gherkin.AstNode.get_single(ast_node, :Scenario) == nil do
      scenario_outline_node = Gherkin.AstNode.get_single(ast_node, :ScenarioOutline)

      if !scenario_outline_node, do: raise "Internal grammar error"

      scenario_outline_line = Gherkin.AstNode.get_single(scenario_outline_node, :ScenarioOutlineLine)
      description           = Gherkin.AstNode.get_single(scenario_outline_node, :Description)
      steps                 = Gherkin.AstNode.get_tokens(scenario_outline_node, :Step)
                                |> Enum.map(fn({_, step}) -> step end)
      examples              = Gherkin.AstNode.get_tokens(scenario_outline_node, :ExamplesDefinition)
                                |> Enum.map(fn({_, step}) -> step end)

      %{
        type: scenario_outline_node.rule_type,
        tags: tags,
        location: scenario_outline_line.location,
        keyword: scenario_outline_line.matched_keyword,
        name: scenario_outline_line.matched_text,
        description: description,
        steps: steps,
        examples: examples
      }
    else
      scenario_node = Gherkin.AstNode.get_single(ast_node, :Scenario)
      scenario_line = Gherkin.AstNode.get_token(scenario_node, :ScenarioLine)
      description   = Gherkin.AstNode.get_token(scenario_node, :Description)
      steps         = Gherkin.AstNode.get_tokens(scenario_node, :Step)
                       |> Enum.map(fn({_, step}) -> step end)

      %{
        type: ast_node.rule_type,
        tags: tags,
        location: Gherkin.Token.get_location(scenario_line),
        keyword: scenario_line.matched_keyword,
        name: scenario_line.matched_text,
        description: description,
        steps: steps
      }
    end
  end

  def transform_node(ast_node = %Gherkin.AstNode{rule_type: :ExamplesDefinition}) do
    examples_node  = Gherkin.AstNode.get_single(ast_node, :Examples)
    examples_line  = Gherkin.AstNode.get_token(examples_node, :ExamplesLine)
    description    = Gherkin.AstNode.get_token(examples_node, :Description)
    examples_table = Gherkin.AstNode.get_single(examples_node, :ExamplesTable)

    %{
      type: examples_node.rule_type,
      tags: get_tags(examples_node),
      description: description,
      keyword: examples_line.matched_keyword,
      location: examples_line.location,
      name: examples_line.matched_text,
      table_body: Gherkin.DataTable.get_table_body(examples_table),
      table_header: Gherkin.DataTable.get_table_header(examples_table)
    }
  end

  def transform_node(ast_node = %Gherkin.AstNode{rule_type: :ExamplesTable}) do
    %{
      table_header: Gherkin.DataTable.get_table_header(ast_node),
      table_body: Gherkin.DataTable.get_table_body(ast_node)
    }
  end

  def transform_node(ast_node = %Gherkin.AstNode{rule_type: :Description}) do
    Gherkin.AstNode.get_tokens(ast_node, :Other)
      |> Enum.map(fn({_, token}) -> token.line.text end)
      |> Enum.join("\n")
      |> String.trim
  end

  def transform_node(ast_node = %Gherkin.AstNode{rule_type: :Feature}) do
   header = Gherkin.AstNode.get_single(ast_node, :FeatureHeader)

    if header do
      feature_line = Gherkin.AstNode.get_single(header, :FeatureLine)

      if feature_line do
        tags        = get_tags(header)
        background  = Gherkin.AstNode.get_single(ast_node, :Background)
        definitions = Gherkin.AstNode.get_tokens(ast_node, :ScenarioDefinition) |> Enum.map(fn({_, item}) -> item end)
        description = Gherkin.AstNode.get_single(header, :Description)
        language    = feature_line.matched_gherkin_dialect
        children    = List.flatten([background, definitions]) |> Enum.reject(fn(x) -> x == nil end)

        %{
          type: ast_node.rule_type,
          tags: tags,
          description: description,
          location: feature_line.location,
          language: feature_line.matched_gherkin_dialect,
          keyword: feature_line.matched_keyword,
          name: feature_line.matched_text,
          children: children
        }
      end
    end
  end

  def transform_node(ast_node = %Gherkin.AstNode{rule_type: :GherkinDocument}) do
    feature  = Gherkin.AstNode.get_single(ast_node, :Feature)
    comments = Gherkin.AstNode.get_tokens(ast_node, :Comment) |> Enum.map(fn({_, item}) -> item end)

    %{
      type: ast_node.rule_type,
      feature: feature,
      comments: comments
    }
  end

  defp get_tags(ast_node) do
    tags_node = Gherkin.AstNode.get_single(ast_node, :Tags)

    if tags_node == nil do
      []
    else
      tokens = Gherkin.AstNode.get_tokens(tags_node, :TagLine)
                 |> Enum.map(fn({_, item}) -> item end)
                 |> Enum.flat_map(fn(item) -> item.matched_items end)
                 |> Enum.map(fn(item) -> 
                      %{
                        type: :Tag,
                        location: Gherkin.Token.get_location(item),
                        name: item.matched_text
                      }
                    end)

      tokens
    end
  end
end

defmodule Gherkin.AstBuilderException do 
  defexception message: "Error building AST"
end