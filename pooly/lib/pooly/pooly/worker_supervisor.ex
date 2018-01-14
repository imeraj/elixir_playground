defmodule Pooly.WorkerSupervisor do
	@moduledoc false

	use Supervisor

	def start_link({_,_,_} = mfa) do
		Supervisor.start_link(__MODULE__, mfa)
	end

	def init({m, f, a} = _state) do
		worker_opts = [restart: :permanent, function: f]

		children = [worker(m, a, worker_opts)]
		opts = [strategy: :simple_one_for_one]

		supervise(children, opts)
	end
end
