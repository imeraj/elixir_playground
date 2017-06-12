defmodule Blitzy do
  use Application

  @moduledoc false

  def start(_type, _args) do
    Blitzy.Supervisor.start_link(:ok)
  end

end