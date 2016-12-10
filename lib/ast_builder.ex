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
end