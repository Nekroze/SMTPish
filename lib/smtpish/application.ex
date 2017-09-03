defmodule SMTPish.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    case Code.ensure_loaded(ExSync) do
      {:module, ExSync} ->
        ExSync.start()
      {:error, :nofile} ->
        :ok
    end

    # List all child processes to be supervised
    children = [
      Honeydew.queue_spec(:targets),
      Honeydew.worker_spec(:targets, {SMTPish.Targets, []}, num: SMTPish.Settings.config(:workers), init_retry_secs: 10),
      worker(:gen_smtp_server, [
        SMTPish.Ingest,
        [[port: SMTPish.Settings.config(:port)]],
      ]),
      worker(SMTPish.Dispatcher, []),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SMTPish.Supervisor]
    SMTPish.Settings.runtime_config()
    Supervisor.start_link(children, opts)
  end
end
