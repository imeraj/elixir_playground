# Ring

* To kill using :normal exit:
   pids |> Enum.shuffle |> List.first |> Process.exit(:kill)

* To check if processes are alive:
   pids |> Enum.map(fn pid -> Process.alive?(pid) end)

* To get info about process links:
	 pids |> List.first |> Process.info(:links)

* To send signal to a process:
	 pids |> Enum.map(fn pid -> send(pid, :trap_exit) end)



