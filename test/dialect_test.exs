defmodule GherkinDialectTest do 
  use ExUnit.Case
  doctest Gherkin.Dialect

  test "dialects returns the dialects file" do 
    {_, json}     = Path.expand("lib/gherkin-languages.json") |> File.read
    {_, contents} = JSON.decode(json)

    # {_, json}     = JSON.decode(contents)

    assert Gherkin.Dialect.dialects == contents
  end
end