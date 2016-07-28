defmodule GherkinTagTest do
  use ExUnit.Case
  doctest Gherkin.Tag

  test ".get_tags\\1 with GherkinLine returns the tags" do
    tags = %Gherkin.GherkinLine{text: "@foo @bar @baz", line_number: 1}

    expected_output = [
      %Gherkin.Tag{text: "@foo", column: 1},
      %Gherkin.Tag{text: "@bar", column: 6},
      %Gherkin.Tag{text: "@baz", column: 11}
    ]
    
    assert Gherkin.Tag.get_tags(tags) == expected_output
  end
end