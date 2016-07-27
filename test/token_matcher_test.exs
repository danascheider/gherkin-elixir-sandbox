defmodule GherkinTokenMatcherTest do 
  use ExUnit.Case
  doctest Gherkin.TokenMatcher

  test ".match_title_line\\3 when the line doesn't match returns false" do
    type     = :Step
    token    = %Gherkin.Token{matched_type: type, line: %Gherkin.GherkinLine{text: "Foo bar baz"}}
    keywords = ["Given", "When", "Then"]

    assert Gherkin.TokenMatcher.match_title_line(token, type, keywords) == false
  end
end