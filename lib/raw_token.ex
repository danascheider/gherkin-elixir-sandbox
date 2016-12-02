defmodule Gherkin.RawToken do
  defstruct line: %Gherkin.Line{text: nil}, location: %{line: 1}
end