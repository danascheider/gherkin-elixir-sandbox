defmodule GherkinTagTest do
  use ExUnit.Case
  doctest Gherkin.Tag

  test ".tags\\1 returns the tags" do
    input = "   @one @two"

    assert Gherkin.Tag.tags(input) == [
      %Gherkin.Tag{text: "one", column: 4},
      %Gherkin.Tag{text: "two", column: 9}
    ]
  end
end