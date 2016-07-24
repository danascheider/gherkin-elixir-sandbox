defmodule Gherkin.AstNode do 
  def add(node, child) do 
    new_sub_items = Map.get(node, :sub_items) |> List.insert_at(-1, child)
    Map.merge(node, %{sub_items: new_sub_items})
  end

  def get_single(node, key) do 
    {_, value} = List.keyfind(Map.get(node, :sub_items), key, 0)
    value
  end
end