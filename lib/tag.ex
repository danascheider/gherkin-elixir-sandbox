defmodule Gherkin.Tag do
  defstruct column: 1, text: ""

  def tags([], column) do
    []
  end

  def tags([head | tail], column) do
    [ %Gherkin.Tag{text: String.trim(head), column: column} ] ++ tags(tail, String.length(head) + column + 1)
  end

  def tags(tags) do
    starting_column = String.length(tags) - (String.trim_leading(tags) |> String.length) + 1
    all_tags        = String.split(tags, "@") |> Enum.slice(1..-1)

    tags(all_tags, starting_column)
  end
end