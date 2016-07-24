defmodule Gherkin.AstBuilder do 
  def start_rule(rule_type), do: %Gherkin.AstNode{rule_type: rule_type}
end