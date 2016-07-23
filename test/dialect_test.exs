defmodule GherkinDialectTest do 
  use ExUnit.Case
  doctest Gherkin.Dialect

  test "returns keywords for the language" do 
    {_, json}     = Path.expand("lib/gherkin-languages.json") |> File.read
    {_, dialects} = JSON.decode(json)

    assert Gherkin.Dialect.for("it") == Map.get(dialects, "it")
  end

  test "returns feature keywords" do 
    {_, json}     = Path.expand("lib/gherkin-languages.json") |> File.read
    {_, dialects} = JSON.decode(json)

    assert Gherkin.Dialect.feature_keywords("it") == [ "Funzionalità" ]
  end
end