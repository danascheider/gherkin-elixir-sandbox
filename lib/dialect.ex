defmodule Gherkin.Dialect do 
  @dialect_path Path.expand("./lib/gherkin-languages.json")

  {_, json}     = File.read(@dialect_path)
  {_, contents} = JSON.decode(json)

  @dialects contents

  def for(lang), do: Map.get(@dialects, lang)

  def feature_keywords(lang), do: fetch(lang, "feature")

  def scenario_keywords(lang), do: fetch(lang, "scenario")

  def scenario_outline_keywords(lang), do: fetch(lang, "scenarioOutline")

  def examples_keywords(lang), do: fetch(lang, "examples")

  def background_keywords(lang), do: fetch(lang, "background")

  defp fetch(lang, keyword), do: Gherkin.Dialect.for(lang) |> Map.get(keyword)
end