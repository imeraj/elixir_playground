use Mix.Config

defmodule Blitzy.CLI do
  require Logger

  @moduledoc false

  # ./blitzy -n [requests] [url]
  def main(args) do
    Application.get_env(:blitzy, :master_node)
    |> Node.start()

    Application.get_env(:blitzy, :slave_nodes)
    |> Enum.each(&Node.connect(&1))

    args
    |> parse_args
    |> process_options([node()|Node.list()])
  end

  defp parse_args(args) do
    OptionParser.parse(args, aliases: [n: :requests],
                             strict: [requests: :integer])
  end

  defp process_options(options, nodes) do
    case options do
      {[requests: n], [url], []} ->
            Blitzy.Caller.do_requests(n, url, nodes)
      _ ->
            do_help()
    end
  end

  defp do_help do
    IO.puts """
    Usage:
    blitzy -n [requests] [url]

    Options:
    -n, [--requests]      # Number of requests

    Example:
    ./blitzy -n 100 http://www.bieberfever.com
    """
    System.halt(0)
    end

end
