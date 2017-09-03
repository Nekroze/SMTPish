defmodule SMTPish.Ingest do
  require Logger
  @behaviour :gen_smtp_server_session

  def init(hostname, session_count, _address, _options) do
    if session_count > SMTPish.Settings.config(:session_limit) do
      Logger.warn 'SMTP server connection limit exceeded'
      {:stop, :normal, ['421 ', hostname, ' is too busy to accept mail right now']}
    else
      banner = [hostname, ' ESMTP']
      state = %{
        :to => SMTPish.Settings.config(:whitelist_to),
        :from => SMTPish.Settings.config(:whitelist_from)
      }
      {:ok, banner, state}
    end
  end

  def handle_MAIL(_from, %{:from => []}=state), do: {:ok, state}
  def handle_MAIL(from, %{:from => whitelist}=state) do
    if Enum.member?(whitelist, from) do
      {:ok, state}
    else
      Logger.warn "Ignoring inbound email from #{from}"
      {:error, "sender blocked", state}
    end
  end

  def handle_RCPT(_to, %{:to => []}=state), do: {:ok, state}
  def handle_RCPT(to, %{:to => whitelist}=state) do
    if Enum.member?(whitelist, to) do
      {:ok, state}
    else
      Logger.warn "Ignoring inbound email to #{to}"
      {:error, "recipient blocked", state}
    end
  end

  def handle_DATA(_from, _to, data, state) do
    SMTPish.Dispatcher.dispatch(data)
    {:ok, 'handled', state}
  end

  def code_change(_OldVsn, state, _Extra), do: {:ok, state}
  def terminate(reason, state), do: {:ok, reason, state}

  def handle_HELO(_hostname, state), do: {:ok, state}
  def handle_MAIL_extension(_extension, state), do: {:ok, state}
  def handle_RCPT_extension(_to, state), do: {:ok, state}
  def handle_RSET(state), do: state
  def handle_STARTTLS(state), do: state
  def handle_info(_info, state), do: {:noreply, state}

  def handle_EHLO(_hostname, extensions, state) do
    my_extensions = [ {'STARTTLS', true} | extensions ]
    {:ok, my_extensions, state}
  end

  def handle_VRFY(_, state) do
    {:error, '252 VRFY disabled by policy, just send some mail', state}
  end

  def handle_other(verb, _, state) do
    {['500 Error: command not recognized : \'', verb, '\''], state}
  end

end
