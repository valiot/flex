defmodule Flex.MixProject do
  use Mix.Project

  def project do
    [
      app: :flex,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      name: "FLex",
      package: package(),
      source_url: "https://github.com/valiot/flex",
      aliases: aliases(),
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]

    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description() do
    "A toolkit for fuzzy logic, this library includes functions for creating fuzzy variables, sets, rules to create a Fuzzy Logic System (FLS)."
  end

  defp aliases do
    [docs: ["docs", &copy_images/1]]
  end

  defp copy_images(_) do
    File.ls!("assets")
    |> Enum.each(fn x ->
      File.cp!("assets/#{x}", "doc/assets/#{x}")
    end)
  end

  defp package() do
    [
      files: [
        "lib",
        "test",
        "mix.exs",
        "README.md",
        "LICENSE"
      ],
      maintainers: ["valiot"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/valiot/flex"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end
end
