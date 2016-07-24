defmodule Gherkin.AstBuilder do 
  def start_rule(stack, rule_type) do
    Enum.concat(stack, [ %Gherkin.AstNode{rule_type: rule_type} ])
  end
end