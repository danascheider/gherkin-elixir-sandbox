defmodule Gherkin.AstBuilder do
  def reset do
    %{
      stack: [%Gherkin.AstNode{rule_type: :None}],
      comments: []
    }
  end

  def start_rule(stack, rule_type) do
    List.insert_at(stack, -1, %Gherkin.AstNode{rule_type: rule_type})
  end

  def current_node(stack) do
    List.last(stack)
  end

  def transform_node(ast_node = %Gherkin.AstNode{rule_type: :Step, sub_items: items}) do
    arg = Gherkin.AstNode.get_single(ast_node, :DataTable) || Gherkin.AstNode.get_single(ast_node, :DocString)

    %{
      type: :Step,
      location: Gherkin.AstNode.get_single(ast_node, :StepLine).location,
      keyword: Gherkin.AstNode.get_single(ast_node, :StepLine).matched_keyword,
      text: Gherkin.AstNode.get_single(ast_node, :StepLine).matched_text,
      argument: arg
    }
  end

  def transform_node(ast_node = %Gherkin.AstNode{rule_type: :DocString, sub_items: _}) do
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

  def transform_node(ast_node = %Gherkin.AstNode{rule_type: :Background, sub_items: _}) do
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
end