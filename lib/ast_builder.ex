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
end