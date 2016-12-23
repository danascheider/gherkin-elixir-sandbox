defmodule Gherkin.ParserContext do
  defstruct language: "en",
            active_docstring_separator: nil,
            stack: [],
            queue: [],
            comments: []

  def shift(context, index) do
    {List.first(context.stack), Enum.drop(context.stack, 1)}
  end
end