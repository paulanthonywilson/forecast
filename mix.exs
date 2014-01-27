defmodule Forecast.Mixfile do
  use Mix.Project

  def project do
    [ app: :forecast,
      version: "0.0.1",
      elixir: "~> 0.12.2",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [mod: { Forecast, [] }]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat" }
  defp deps do
    [
      {:httpotion, github: "myfreeweb/httpotion"},
      {:jsonex, "2.0", github: "marcelog/jsonex"},
      {:ex_doc, github: "elixir-lang/ex_doc"},
      ]
  end
end