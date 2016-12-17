defmodule Gherkin.AstBuilder do
  def reset do
    %{
      stack: [%Gherkin.AstNode{rule_type: :None}],
      comments: []
    }
  end

  def start_rule(context, rule_type) do
    %{context | stack: List.insert_at(context.stack, -1, %Gherkin.AstNode{rule_type: rule_type})}
  end

  def end_rule(context) do
    ast_node  = Enum.at(context.stack, -1)
    new_stack = List.delete_at(context.stack, -1)
    new_node  = Gherkin.AstNode.add(current_node(new_stack), ast_node.rule_type, ast_node)

    %{context | stack: List.replace_at(new_stack, -1, new_node)}
  end

  def current_node(stack) do
    List.last(stack)
  end

  def build(context, token = %{matched_type: :Comment}) do
    {
      context.stack, 
      List.insert_at(
        context.comments, 
        -1, 
        %{type: :Comment, location: token.location, text: token.matched_text}
      )
    }
  end

  def build(context, token) do
    {
      List.replace_at(
        context.stack, 
        -1, 
        Gherkin.AstNode.add(current_node(context.stack) |> transform_node, token.matched_type, token)
      ), 
      context.comments
    }
  end

  def transform_node(ast_node, comments \\ [])

  def transform_node(ast_node = %Gherkin.AstNode{rule_type: :Step, sub_items: items}, _) do
    arg = Gherkin.AstNode.get_single(ast_node, :DataTable) || Gherkin.AstNode.get_single(ast_node, :DocString)

    %{
      type: :Step,
      location: Gherkin.AstNode.get_single(ast_node, :StepLine).location,
      keyword: Gherkin.AstNode.get_single(ast_node, :StepLine).matched_keyword,
      text: Gherkin.AstNode.get_single(ast_node, :StepLine).matched_text,
      argument: arg
    }
  end

  def transform_node(ast_node = %{rule_type: :DocString}, _) do
    separator    = Gherkin.AstNode.get_single(ast_node, :DocStringSeparator)

    content_type = if separator.matched_text == "" do
      nil
    else
      separator.matched_text
    end

    content = Gherkin.AstNode.get_items(ast_node, :Other) 
                |> Enum.map(fn(t) -> t.matched_text end)
                |> Enum.join("\n")

    %{
      type: :DocString,
      location: separator.location,
      content_type: content_type,
      content: content
    }
  end

  def transform_node(ast_node = %{rule_type: :Background}, _) do
    background_line = Gherkin.AstNode.get_single(ast_node, :BackgroundLine)

    %{
      type: :Background,
      location: background_line.location,
      keyword: background_line.matched_keyword,
      name: background_line.matched_text,
      description: Gherkin.AstNode.get_single(ast_node, :Description),
      steps: Gherkin.AstNode.get_items(ast_node, :Step)
    }
  end

  def transform_node(ast_node = %{rule_type: :ScenarioDefinition}, _) do
    tags          = Gherkin.AstNode.get_tags(ast_node)
    scenario_node = Gherkin.AstNode.get_single(ast_node, :Scenario)

    if scenario_node == nil do 
      scenario_outline_node = Gherkin.AstNode.get_single(ast_node, :ScenarioOutline)

      %{
        type: :ScenarioOutline
      }

      raise "Not implemented for scenario outline yet"
    else
      %{
        type: :Scenario,
        tags: tags,
        location: Gherkin.AstNode.get_single(scenario_node, :ScenarioLine).location,
        keyword: Gherkin.AstNode.get_single(scenario_node, :ScenarioLine).matched_keyword,
        name: Gherkin.AstNode.get_single(scenario_node, :ScenarioLine).matched_text,
        description: Gherkin.AstNode.get_single(scenario_node, :Description),
        steps: Gherkin.AstNode.get_items(scenario_node, :Step)
      }
    end
  end

  def transform_node(ast_node = %{rule_type: :GherkinDocument}, comments) do
    %{
      type: :GherkinDocument,
      feature: Gherkin.AstNode.get_single(ast_node, :Feature),
      comments: comments
    }
  end
end