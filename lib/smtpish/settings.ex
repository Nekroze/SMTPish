defmodule SMTPish.Settings do
  use Confex,
    otp_app: :smtpish,
    port: {:system, :integer, "PORT", 2500},
    workers: {:system, :integer, "WORKERS", 5},
    logging: {:system, :atom, "LOG_LEVEL", :warn},
    session_limit: {:system, :integer, "SESSION_LIMIT", 50},
    whitelist_from: {:system, :list, "WHITELIST_FROM", []},
    whitelist_to: {:system, :list, "WHITELIST_TO", []},
    targets: {:system, :list, "TARGETS", ["echo"]},
    slack_token: {:system, :string, "SLACK_TOKEN", ""},
    dynamic_sender: {:system, :boolean, "DYNAMIC_SENDER", true},
    default_sender: {:system, :boolean, "DEFAULT_SENDER", true},
    dynamic_destination: {:system, :string, "DYNAMIC_DESTINATION", "SMTPish"},
    default_destination: {:system, :string, "DEFAULT_DESTINATION", "SMTPish"}

  def config(atom) do
    config()[atom]
  end

  def runtime_config() do
    Application.put_env(:logger, :level, config(:logging))
    Application.put_env(:slack, :api_token, config(:slack_token))
    :ok
  end

end
