use Mix.Config

defmodule Loadtester.CLI do
    require Logger

    def main(args) do
        Application.get_env(:Loadtester, :master_node)
        |> IO.puts

        Application.get_env(:Loadtester, :master_node)
        |> Node.start

        Application.get_env(:Loadtester, :slave_nodes)
        |> Enum.each(&Node.connect(&1))

        args
        |> parse_args
        |> process_options([node()|Node.list])
    end

    defp parse_args(args) do
        OptionParser.parse(args, aliases: [n: :requests], strict: [requests: :integer])
    end

    defp process_options(options, nodes) do
        case options do
            {[requests: n], [url], []} ->
                do_requests(n, url, nodes)
            _ ->
                do_help()
        end
    end

    defp do_requests(n_requests, url, nodes) do
        Logger.info "Pummeling #{url} with #{n_requests} requests"

        total_nodes = Enum.count(nodes)
        req_per_node = div(n_requests, total_nodes)

        nodes
        |> Enum.flat_map(fn node ->
            1..req_per_node |> Enum.map(fn _ ->
                Task.Supervisor.async({Loadtester.TasksSupervisor, node},
                    Loadtester.Worker, :start, [url])
                end)
            end)
        |> Enum.map(&Task.await(&1))
    end

    defp do_help do
        IO.puts """
        Usage:
        loadtester -n [requests] [url]

        Options:
        -n, [--requests]      # Number of requests

        Example:
        ./loadtester -n 100 http://www.bieberfever.com
        """
        System.halt(0)
    end
end
