defmodule Gherkin.Dialect do 
  @dialect_path Path.expand("./lib/gherkin-languages.json")

  {_, json}     = File.read(@dialect_path)
  {_, contents} = JSON.decode(json)

  @dialects contents

  def for(lang), do: Map.get(@dialects, lang)

  def feature_keywords(lang) do 
    Gherkin.Dialect.for(lang) |> Map.get("feature")
  end

  def scenario_keywords(lang) do 
    Gherkin.Dialect.for(lang) |> Map.get("scenario")
  end
end