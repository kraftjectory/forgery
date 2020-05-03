defmodule Fortory.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/craftjectory/fortory"

  def project() do
    [
      app: :fortory,
      version: @version,
      elixir: "~> 1.6",
      deps: deps(),

      # Hex.
      package: package(),
      description: description(),

      # Docs.
      name: "Fortory",
      docs: docs()
    ]
  end

  def application(), do: []

  defp deps() do
    [
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "A slim test data generator that does not compromise extensibility"
  end

  defp package() do
    [
      maintainers: ["Aleksei Magusev", "Cẩm Huỳnh"],
      licenses: ["ISC"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs() do
    [
      main: "Fortory",
      extras: ["README.md"],
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end
end
