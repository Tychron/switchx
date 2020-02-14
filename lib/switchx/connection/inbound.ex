defmodule SwitchX.Connection.Inbound do
  @mode :inbound
  @socket_opts [:binary, active: :once, packet: :line]
  @timeout 5_000

  def start_link(opts) do
    host = Keyword.fetch!(opts, :host)
    port = Keyword.fetch!(opts, :port)

    case perform_connect(host, port, @socket_opts, @timeout) do
      {:ok, socket} ->
        {:ok, client} = SwitchX.Connection.start_link(self(), socket, @mode)
        :gen_tcp.controlling_process(socket, client)
        {:ok, client}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp perform_connect(host, port, socket_opts, timeout) when is_binary(host) do
    host =
      host
      |> String.split(".")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()

    perform_connect(host, port, socket_opts, timeout)
  end

  defp perform_connect(host, port, socket_opts, timeout) when is_tuple(host) do
    :gen_tcp.connect(host, port, socket_opts, timeout)
  end
end
