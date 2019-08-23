defmodule Htop.MixProject do
  use Mix.Project
  @version "0.1.0"

  def project do
    [
      app: :htop,
      version: @version,
      elixir: "~> 1.9",
      docs: [extras: ["README.md"], main: "readme", source_ref: "v#{@version}"],
      source_url: "https://github.com/lorenzosinisi/htop",
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.16", only: :dev},
      {:earmark, "~> 1.2", only: :dev}
    ]
  end

  defp description do
    """
    Htop for Elixir.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Lorenzo Sinisi"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/lorenzosinisi/htop"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Htop.Application, []}
    ]
  end
end
