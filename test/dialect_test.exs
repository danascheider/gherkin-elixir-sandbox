defmodule DialectTest do
  use ExUnit.Case
  doctest Gherkin.Dialect

  test ".for/1 returns a struct" do
    french = %Gherkin.Dialect{
               and: ["* ", "Et que ", "Et qu'", "Et "],
               background: ["Contexte"],
               but: ["* ", "Mais que ", "Mais qu'", "Mais "],
               examples: ["Exemples"],
               feature: ["Fonctionnalité"],
               given: ["* ", "Soit ", "Etant donné que ", "Etant donné qu'", "Etant donné ", "Etant donnée ", "Etant donnés ", "Etant données ", "Étant donné que ", "Étant donné qu'", "Étant donné ", "Étant donnée ", "Étant donnés ", "Étant données "],
               name: "French",
               native: "français",
               scenario: ["Scénario"],
               scenarioOutline: ["Plan du scénario", "Plan du Scénario"],
               then: ["* ", "Alors "],
               when: ["* ", "Quand ", "Lorsque ", "Lorsqu'"]
             }

    assert Gherkin.Dialect.for("fr") == french
  end

  test ".and_keywords/1 returns the and keywords for the given language" do
    assert Gherkin.Dialect.and_keywords("fr") == ["* ", "Et que ", "Et qu'", "Et "]
  end

  test ".background_keywords/1 returns the background keywords for the given language" do
    assert Gherkin.Dialect.background_keywords("fr") == ["Contexte"]
  end

  test ".but_keywords/1 returns the but keywords for the given language" do
    assert Gherkin.Dialect.but_keywords("it") == ["* ", "Ma "]
  end

  test ".examples_keywords/1 returns the examples keywords for the given language" do
    assert Gherkin.Dialect.examples_keywords("es") == ["Ejemplos"]
  end

  test ".feature_keywords/1 returns the feature keywords for the given language" do
    assert Gherkin.Dialect.feature_keywords("it") == ["Funzionalità"]
  end

  test ".given_keywords/1 returns the given keywords for the given language" do
    assert Gherkin.Dialect.given_keywords("it") == ["* ", "Dato ", "Data ", "Dati ", "Date "]
  end

  test ".scenario_keywords/1 returns the scenario keywords for the given language" do
    assert Gherkin.Dialect.scenario_keywords("fr") == ["Scénario"]
  end

  test ".scenario_outline_keywords/1 returns the scenario outline keywords for the given language" do
    assert Gherkin.Dialect.scenario_outline_keywords("fr") ==  ["Plan du scénario", "Plan du Scénario"]
  end

  test ".then_keywords/1 returns the then keywords for the given language" do
    assert Gherkin.Dialect.then_keywords("fr") == ["* ", "Alors "]
  end

  test ".when_keywords/1 returns the when keywords for the given language" do
    assert Gherkin.Dialect.when_keywords("it") == ["* ", "Quando "]
  end

  test ".step_keywords/1 returns all the step keywords for the given language" do
    assert Gherkin.Dialect.step_keywords("en") == ["* ", "Given ", "When ", "Then ", "And ", "But "]
  end
end
