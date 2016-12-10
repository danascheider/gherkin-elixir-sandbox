defmodule Gherkin.AstNode do
  defstruct rule_type: :None,
            sub_items: %{}

  def add(ast_node = %Gherkin.AstNode{rule_type: type, sub_items: items}, rule_type, object) do
    list = get_items(ast_node, rule_type) |> List.insert_at(-1, object)

    sub_items = if Map.has_key?(items, rule_type) do
      %{ items | rule_type => list }
    else
      Map.merge(items, %{rule_type => list})
    end

    %Gherkin.AstNode{rule_type: type, sub_items: sub_items}
  end

  def get_items(ast_node, rule_type) do
    if Map.has_key?(ast_node.sub_items, rule_type) do
      {:ok, items} = Map.fetch(ast_node.sub_items, rule_type)
      items
    else
      []
    end
  end

  def get_single(ast_node, rule_type) do
    get_items(ast_node, rule_type) |> List.first
  end
end