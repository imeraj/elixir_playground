defmodule Loadtester do
    def run(n_workers, url) when n_workers > 0 do
        worker_func = fn -> Loadtester.Worker.start(url) end

        1..n_workers
        |> Enum.map(fn _ -> Task.async(worker_func) end)
        |> Enum.map(&Task.await(&1, :infinity))
    end
end
