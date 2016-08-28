Code.eval_file "tasks/readme.exs"
defmodule Traverse.Mixfile do
  use Mix.Project

  def project do
    [app: :traverse,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     elixirc_paths: elixirc_paths(Mix.env),
     description:   description(),
     package:       package(),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  defp description do
    """
    Traverse is a toolset to walk arbitrary Elixir Datastructures.

    It allows for _uninformed_ traversal and for _informed_ or _structured_ traversal
    as in trees.

    There are convenience implementations for trees and for ASTs.
    """
  end

  defp package do
    [
      files:       [ "lib", "mix.exs", "README.md", "LICENSE" ],
      maintainers: [
                     "Robert Dober <robert.dober@gmail.com>"
                   ],
      licenses:    [ "Apache 2 (see the file LICENSE)" ],
      links:       %{
                       "GitHub" => "https://github.com/RobertDober/traverse",
                   }
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.13.0", only: :dev},
      {:excoveralls, "~> 0.5", only: :test},
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]
end
