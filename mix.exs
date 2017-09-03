defmodule SMTPish.Mixfile do
  use Mix.Project

  def project do
    [
      app: :smtpish,
      version: "1.0.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {SMTPish.Application, []},
      extra_applications: [
        :logger,
      ],
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gen_smtp, "~> 0.12.0"},
      {:mail, "~> 0.2.0"},
      {:confex, "~> 3.2"},
      {:slack, "~> 0.12.0"},
      {:honeydew, "~> 1.0.1"},
      {:exsync, "~> 0.2.0", only: :dev},
      {:distillery, "~> 1.4", runtime: false}
    ]
  end

  defp aliases() do
    [
      "prodish": ["init", "compose up"],
      "develop": ["init", "run --no-halt"],
      "init": ["local.hex --force", "local.rebar --force", "deps.get"],
    ]
  end
end
