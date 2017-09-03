defmodule SMTPish.Targets do
  require Logger

  def init(_) do
    {:ok, nil}
  end

  def send(target, email, _state \\ nil) do
    Logger.debug "Sending message to target '#{target}'"
    get_poster(target).([get_destination(email), get_sender(email), get_message(email)])
  end

  def get_poster("slack") do
    &target_slack/1
  end

  def get_poster("echo") do
    &target_echo/1
  end

  def get_poster("exception") do
    &target_exception/1
  end

  def get_poster(target) do
    &(target_unknown(target, &1))
  end

  def target_slack([destination, sender, message]) do
    Slack.Web.Chat.post_message(destination, message, %{username: sender})
  end

  def target_echo([destination, sender, message]) do
    IO.puts "to: #{destination} from: #{sender} message:\n#{message}"
  end

  def target_exception([_destination, _sender, message]) do
    raise message
  end

  def target_unknown(target, [_destination, _sender, _message]) do
    Logger.error "Unknown target '#{target}'"
  end

  def extract_email_username(address) do
    address
    |> String.split("@")
    |> List.first
  end

  def extract_destination(%{:headers => %{"to" => recipients}}) do
    recipients
    |> List.first
    |> extract_email_username
  end

  def extract_sender(%{:headers => %{"from" => from}}) do
    extract_email_username from
  end

  def get_message(%{:body => body, :headers => %{"subject" => subject}}) do
    [subject,body]
    |> Enum.join(":\n")
  end

  def get_destination(email, settings \\ SMTPish.Settings) do
    if settings.config(:dynamic_destination) do
      extract_destination(email)
    else
      settings.config(:default_destination)
    end
  end

  def get_sender(email, settings \\ SMTPish.Settings) do
    if settings.config(:dynamic_sender) do
      extract_sender(email)
    else
      settings.config(:default_sender)
    end
  end

end
