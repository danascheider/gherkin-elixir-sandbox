defmodule Gherkin.Dialect do
  defstruct and: ["* ", "And "],
            background: ["Background"],
            but: ["* ", "But "],
            examples: ["Examples", "Scenarios"],
            feature: ["Feature", "Business Need", "Ability"],
            given: ["* ", "Given "],
            name: "English",
            native: "English",
            scenario: ["Scenario"],
            scenarioOutline: ["Scenario Outline", "Scenario Template"],
            then: ["* ", "Then "],
            when: ["* ", "When "]

  @dialect_path Path.expand("./lib/gherkin-languages.json")

  {:ok, json}     = File.read(@dialect_path)
  {:ok, contents} = JSON.decode(json)

  @dialects contents
  
  # TODO: check if for\1 is used elsewhere, merge into fetch\2 if not 
  def for(dialect) do
    language = Map.get(@dialects, dialect)
               |> Enum.reduce(%{}, fn({key, val}, acc) -> Map.put(acc, String.to_atom(key), val) end)

    %Gherkin.Dialect{} |> Map.merge(language)
  end

  def and_keywords(dialect), do: fetch(dialect, :and)

  def background_keywords(dialect), do: fetch(dialect, :background)

  def but_keywords(dialect), do: fetch(dialect, :but)

  def examples_keywords(dialect), do: fetch(dialect, :examples)

  def feature_keywords(dialect), do: fetch(dialect, :feature)

  def given_keywords(dialect), do: fetch(dialect, :given)

  def scenario_keywords(dialect), do: fetch(dialect, :scenario)

  def scenario_outline_keywords(dialect), do: fetch(dialect, :scenarioOutline)

  def then_keywords(dialect), do: fetch(dialect, :then)

  def when_keywords(dialect), do: fetch(dialect, :when)

  def step_keywords(dialect) do
    given_keywords(dialect) ++ when_keywords(dialect) ++ then_keywords(dialect) ++ and_keywords(dialect) ++ but_keywords(dialect) |> Enum.uniq
  end

  defp fetch(lang, keyword) do
    Gherkin.Dialect.for(lang) |> Map.get(keyword)
  end
end
