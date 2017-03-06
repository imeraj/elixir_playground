defmodule Loadtester do
  use Application

  def start(_type, _args) do
    Loadtester.Supervisor.start_link(:ok)
  end
end
