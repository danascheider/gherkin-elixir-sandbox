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
end