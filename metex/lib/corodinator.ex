defmodule Metex.Coordinator do
  def loop(results \\ [], results_expected) do
    receive do
      {:ok, result} ->
        new_results = [result|results]
        if results_expected == Enum.count(new_results) do
          send self(), :exit
        end
        loop(new_results, results_expected)
      :exit ->
        IO.puts(results |> Enum.sort |> Enum.join(", "))
      _ ->
        loop(results, results_expected)
    end
  end

  def dispatcher(cities) do
      coordinator_pid = spawn(Metex.Coordinator, :loop, [[], Enum.count(cities)])

      cities
      |> Enum.each(fn city ->
          worker_pid = spawn(Metex.Worker, :loop, [])
          send worker_pid, {coordinator_pid, city}
      end)
  end
end
