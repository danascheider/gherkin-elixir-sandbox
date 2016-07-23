defmodule GherkinDialectTest do 
  use ExUnit.Case
  doctest Gherkin.Dialect

  test "returns keywords for the language" do 
    {_, json}     = Path.expand("lib/gherkin-languages.json") |> File.read
    {_, dialects} = JSON.decode(json)

    assert Gherkin.Dialect.for("it") == Map.get(dialects, "it")
  end

  test "feature_keywords returns feature keywords" do 
    assert Gherkin.Dialect.feature_keywords("it") == [ "Funzionalità" ]
  end

  test "scenario_keywords returns scenario keywords" do 
    assert Gherkin.Dialect.scenario_keywords("it") == [ "Scenario" ]
  end

  test "scenario_outline_keywords returns scenario outline keywords" do 
    assert Gherkin.Dialect.scenario_outline_keywords("it") == [ "Schema dello scenario" ]
  end

  test "examples_keywords returns examples keywords" do 
    assert Gherkin.Dialect.examples_keywords("it") == [ "Esempi" ]
  end

  test "background_keywords returns background keywords" do 
    assert Gherkin.Dialect.background_keywords("it") == [ "Contesto" ]
  end

  test "given_keywords returns given keywords" do 
    assert Gherkin.Dialect.given_keywords("it") == [ "* ", "Dato ", "Data ", "Dati ", "Date " ]
  end

  test "when_keywords returns when keywords" do 
    assert Gherkin.Dialect.when_keywords("it") == [ "* ", "Quando " ]
  end

  test "then_keywords returns then keywords" do 
    assert Gherkin.Dialect.then_keywords("it") == [ "* ", "Allora " ]
  end
end