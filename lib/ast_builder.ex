defmodule Gherkin.AstBuilder do
  def reset do
    %{
      stack: [%Gherkin.AstNode{rule_type: :None}],
      comments: []
    }
  end
end