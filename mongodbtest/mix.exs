defmodule MongodbTest.Mixfile do
  use Mix.Project

  def project do
    [
      app: :mongodbtest,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:mongodb, :poolboy],
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
	    {:mongodb, "0.4.3"},
	    {:poolboy, "1.5.1"}
    ]
  end
end