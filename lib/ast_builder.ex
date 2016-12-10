defmodule Gherkin.AstBuilder do
  def reset do
    [%Gherkin.AstNode{rule_type: :None}]
  end
end