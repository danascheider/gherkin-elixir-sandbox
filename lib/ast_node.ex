defmodule Gherkin.AstNode do 

  defstruct sub_items: [], rule_type: :FeatureHeader

  def add(node, child) do 
    new_sub_items = Map.get(node, :sub_items) |> List.insert_at(-1, child)
    %Gherkin.AstNode{node | sub_items: new_sub_items}
  end

  def get_single(node, key) do 
    if tuple = Map.get(node, :sub_items) |> List.keyfind(key, 0) do
      {_, child} = tuple
      child
    end
  end

  def get_token(node, key), do: get_single(node, key)

  def get_items(node, key) do 
    Map.get(node, :sub_items) 
      |> Enum.filter(fn(x) -> Tuple.to_list(x) |> List.first == key end)
  end

  def get_tokens(node, key), do: get_items(node, key)
end