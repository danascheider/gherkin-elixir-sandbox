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

  def transform_node(ast_node = %Gherkin.AstNode{rule_type: :DocString}) do 
    {_, separator_token} = Gherkin.AstNode.get_token(ast_node, :DocStringSeparator)
    content_type         = separator_token.matched_text
    line_tokens          = Gherkin.AstNode.get_tokens(ast_node, :Other)
    content              = Enum.map(line_tokens, fn({:Other, t}) -> t.matched_text end) |> Enum.join("\n")

    %{
      type: ast_node.rule_type,
      location: Gherkin.Token.get_location(separator_token),
      content: content,
      contentType: content_type
    }
  end

  def transform_node(ast_node = %Gherkin.AstNode{rule_type: :DataTable}) do
    rows = Gherkin.DataTable.get_table_rows(ast_node)

    %{
      type: ast_node.rule_type,
      location: List.first(rows).location,
      rows: rows
    }
  end

  def transform_node(ast_node = %Gherkin.AstNode{rule_type: :Background}) do
    {_, background_line} = Gherkin.AstNode.get_token(ast_node, :BackgroundLine)
    {_, description}     = Gherkin.AstNode.get_single(ast_node, :Description)
    steps                = Gherkin.AstNode.get_tokens(ast_node, :Step)
                             |> Enum.map(fn({_, step}) -> step end)

    %{
      type: ast_node.rule_type,
      location: background_line.location,
      keyword: background_line.matched_keyword,
      name: background_line.matched_text,
      description: description,
      steps: steps
    }
  end
end

defmodule Gherkin.AstBuilderException do 
  defexception message: "Error building AST"
end