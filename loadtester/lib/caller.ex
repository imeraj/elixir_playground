defmodule Loadtester.Caller do
    def start(n_workers, url) do
        me = self()

        1..n_workers
        |> Enum.map(fn _ -> spawn(fn -> Loadtester.Worker.start(url, me) end) end)
        |> Enum.map(fn _ ->
            receive do
                x -> x
            end
        end)
    end

end
