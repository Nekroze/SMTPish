defmodule SMTPish.TargetsTest do
  use ExUnit.Case
  doctest SMTPish.Targets

  import ExUnit.CaptureIO

  def fake_email(to \\ "someone", from \\ "test", subject \\ "oi!", message \\ "testage") do
    %{
      :body => message,
      :headers => %{
        "to" => [to],
        "from" => from,
        "subject" => subject
      }
    }
  end

  test "echo target" do
    assert capture_io(fn ->
      SMTPish.Targets.send("echo", fake_email())
    end) == "to: someone from: test message:\noi!:\ntestage\n"
  end
end
