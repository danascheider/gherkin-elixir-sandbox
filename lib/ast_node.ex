defmodule Gherkin.AstNode do 
  def add(node, child) do 
    new_sub_items = Map.get(node, :sub_items) |> Map.merge(child)
    Map.merge(node, %{sub_items: new_sub_items})
  end

  def get_single(node, key) do 
    Map.get(Map.get(node, :sub_items), key)
  end
end