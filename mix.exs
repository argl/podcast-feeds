defmodule Feedme.Mixfile do
  use Mix.Project

  def project do
    [app: :podcast_feeds,
     version: "1.0.0",
     elixir: "~> 1.2",
     description: "Elixir RSS/Atom parser, optimized for POdcast feeds, based on erlsom",
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :tzdata]]
  end

  # Describe Hex.pm package
  def package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/argl/podcast-feeds"}
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:erlsom, "~> 1.2"},
      {:timex, "~> 1.0.0-rc3"},
      {:mix_test_watch, "~> 0.2", only: :dev}
    ]
  end
end
