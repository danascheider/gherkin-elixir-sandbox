defmodule Gherkin.Lexer do 
  defstruct line: 1, location: %{line: 1}

  def tokenize(document) do 
    %Gherkin.Lexer{line: 1, location: %{line: 1}}
  end
end