defmodule Gherkin.AstBuilder do 
  def start_rule(stack, rule_type) do
    Enum.concat(stack, [ %Gherkin.AstNode{rule_type: rule_type} ])
  end

  def transform_node(ast_node = %Gherkin.AstNode{rule_type: :Step}) do
    {_, step_line}  = Gherkin.AstNode.get_token(ast_node, :StepLine)
    argument        = Gherkin.AstNode.get_token(ast_node, :DataTable) || Gherkin.AstNode.get_token(ast_node, :DocString) || nil

    %{
      type: ast_node.rule_type,
      location: Gherkin.Token.get_location(step_line),
      keyword: step_line.matched_keyword,
      arguments: argument,
      text: step_line.matched_text
    }
  end

  def transform_node(ast_node = %Gherkin.AstNode{rule_type: :DocString}) do 
    {_, separator_token} = Gherkin.AstNode.get_token(ast_node, :DocStringSeparator)
    content_type         = separator_token.matched_text
    line_tokens          = Gherkin.AstNode.get_tokens(ast_node, :Other)
    content              = Enum.map(line_tokens, fn({:Other, t}) -> t.matched_text end) |> Enum.join("\n")

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
    {_, background_line} = Gherkin.AstNode.get_token(ast_node, :BackgroundLine)
    {_, description}     = Gherkin.AstNode.get_single(ast_node, :Description)
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
      {_, scenario_outline_node} = Gherkin.AstNode.get_single(ast_node, :ScenarioOutline)

      if !scenario_outline_node, do: raise "Internal grammar error"

      {_, scenario_outline_line} = Gherkin.AstNode.get_single(scenario_outline_node, :ScenarioOutlineLine)
      {_, description}           = Gherkin.AstNode.get_single(scenario_outline_node, :Description)
      steps                      = Gherkin.AstNode.get_tokens(scenario_outline_node, :Step)
                                     |> Enum.map(fn({_, step}) -> step end)
      examples                   = Gherkin.AstNode.get_tokens(scenario_outline_node, :ExamplesDefinition)
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
      {_, scenario_node} = Gherkin.AstNode.get_single(ast_node, :Scenario)
      {_, scenario_line} = Gherkin.AstNode.get_token(scenario_node, :ScenarioLine)
      {_, description}   = Gherkin.AstNode.get_token(scenario_node, :Description)
      steps              = Gherkin.AstNode.get_tokens(scenario_node, :Step)
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

  defp get_tags(ast_node) do
    {_, tags_node} = Gherkin.AstNode.get_single(ast_node, :Tags)

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