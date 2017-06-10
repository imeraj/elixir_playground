defmodule Blitzy.Caller do
   def start(n_workers, url) when n_workers > 0 do
       me = self()
       worker_func = fn -> Blitzy.Worker.start(url, me) end

       1..n_workers
       |> Enum.map(fn _ -> Task.async(worker_func) end)
       |> Enum.map(&Task.await(&1, :infinity))
   end

end