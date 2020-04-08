defmodule BroadwayStock do
  @moduledoc false

  @csv_file "./data/companylist.csv"
  @queue_name "stock_queue"

  def dispatch do
    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Queue.declare(channel, @queue_name, durable: true)

    @csv_file
    |> File.stream!()
    |> Stream.drop(1)
    |> Stream.map(&String.trim(&1, "\n"))
    |> Stream.map(&String.split(&1, ","))
    |> Enum.map(fn columns -> List.first(columns) end)
    |> Enum.each(fn symbol ->
      write_queue(channel, symbol)
    end)

    AMQP.Connection.close(connection)
  end

  defp write_queue(channel, symbol) do
    AMQP.Basic.publish(channel, "", @queue_name, symbol)
  end
end
