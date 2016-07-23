defmodule Gherkin.Dialect do 
  @dialect_path Path.expand("./lib/gherkin-languages.json")

  def dialects do 
    {_, json}     = File.read(@dialect_path)
    {_, contents} = JSON.decode(json)
    contents
  end
end