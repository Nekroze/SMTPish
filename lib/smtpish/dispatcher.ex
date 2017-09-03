defmodule SMTPish.Dispatcher do
  use GenServer
  require Logger

  # Client

  def start_link(settings \\ SMTPish.Settings) do
    GenServer.start_link(__MODULE__, settings.config(:targets), [name: __MODULE__])
  end

  def dispatch(data) do
    GenServer.cast(__MODULE__, {:enqueue, data})
  end

  # Server
  def handle_cast({:enqueue, data}, targets) do
    data
    |> Mail.Parsers.RFC2822.parse
    |> enqueue(targets)
    {:noreply, targets}
  end

  def enqueue(_email, []), do: :ok
  def enqueue(email, [ target | targets ]) do
    Logger.debug "Dispatching to target '#{target}'"
    {:send, [target, email]}
    |> Honeydew.async(:targets)

    enqueue(email, targets)
  end
end
