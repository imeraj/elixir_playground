defmodule KV.Supervisor do
    use Supervisor

    def start_link do
        Supervisor.start_link(__MODULE__, :ok)
    end

    def init(:ok) do
        children  = [
            supervisor(KV.Bucket.Supervisor, []),
            worker(KV.Registry, [KV.Registry])
        ]

        supervise(children, strategy: :rest_for_one)
    end
end
