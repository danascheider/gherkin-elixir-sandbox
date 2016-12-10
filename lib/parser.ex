defmodule Gherkin.Parser do
  def parse(input, _url) do
    %{
      type: :GherkinDocument,
      comments: []
    }
  end
end