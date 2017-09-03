defmodule Mix.Tasks.Compose do
  use Mix.Task

  @shortdoc "Run Docker Compose to start up an orchestrated multi-container
    runtime of this project. Options: up, down, release, build"

  def run(args) do
    case Mix.shell.cmd("docker-compose version", [quiet: true]) do
      0 ->
        compose(args)
      _err -> Mix.shell.error "docker-compose executable not found.
                Installation page: https://docs.docker.com/compose/install"
    end
  end

  def compose(["up"]) do
    Mix.shell.cmd("docker-compose -f docker-compose.prod.yml -f docker-compose.yml build")
    Mix.shell.cmd("docker-compose -f docker-compose.prod.yml -f docker-compose.yml up -d")
  end

  def compose(["down"]) do
    Mix.shell.cmd("docker-compose -f docker-compose.prod.yml -f docker-compose.yml down -v")
  end

end
