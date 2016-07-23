defmodule GherkinDialectTest do 
  use ExUnit.Case
  doctest Gherkin.Dialect

  test "returns keywords for the language" do 
    {_, json}     = Path.expand("lib/gherkin-languages.json") |> File.read
    {_, dialects} = JSON.decode(json)

    assert Gherkin.Dialect.for("it") == Map.get(dialects, "it")
  end

  test "feature_keywords returns feature keywords" do 
    {_, json}     = Path.expand("lib/gherkin-languages.json") |> File.read
    {_, dialects} = JSON.decode(json)

    assert Gherkin.Dialect.feature_keywords("it") == [ "Funzionalità" ]
  end

  test "scenario_keywords returns scenario keywords" do 
    {_, json}     = Path.expand("lib/gherkin-languages.json") |> File.read
    {_, dialects} = JSON.decode(json)

    assert Gherkin.Dialect.scenario_keywords("it") == [ "Scenario" ]
  end

  test "scenario_outline_keywords returns scenario outline keywords" do 
    {_, json}     = Path.expand("lib/gherkin-languages.json") |> File.read
    {_, dialects} = JSON.decode(json)

    assert Gherkin.Dialect.scenario_outline_keywords("it") == [ "Schema dello scenario" ]
  end

  test "examples_keywords returns scenario outline keywords" do 
    {_, json}     = Path.expand("lib/gherkin-languages.json") |> File.read
    {_, dialects} = JSON.decode(json)

    assert Gherkin.Dialect.examples_keywords("it") == [ "Esempi" ]
  end
end