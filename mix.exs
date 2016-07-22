defmodule Gherkin.Mixfile do
  use Mix.Project

  def project do
    [app: :gherkin,
     version: "0.1.0",
     elixir: "~> 1.3",
     maintainers: [ "dana.scheider@gmail.com" ],
     licenses: [ "MIT" ],
     description: description(),
     links: %{"GitHub" => "https://github.com/cucumber/gherkin-elixir", "Docs" => "http://cucumber.io"},
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    []
  end

  defp description do 
    """
    The Elixir implementation of Gherkin.
    """
  end
end
