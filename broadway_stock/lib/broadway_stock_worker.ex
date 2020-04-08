defmodule BroadwayStock.Worker do
  use Broadway

  import Api.Worker, only: [get_quote: 1]

  alias Broadway.Message

  @queue_name "stock_queue"

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: BroadwayStock.Worker,
      producer: [
        module: {BroadwayRabbitMQ.Producer, queue: @queue_name},
        transformer: {__MODULE__, :transform, []},
        concurrency: 1,
        rate_limiting: [
          allowed_messages: 1,
          interval: 12_000
        ]
      ],
      processors: [
        default: [
          concurrency: 1
        ]
      ]
    )
  end

  @impl true
  def handle_message(_, message, _) do
    message
    |> Message.update_data(fn symbol ->
      price =
        symbol
        |> get_quote

      display_quote(symbol, price)
    end)
  end

  def transform(event, _opts) do
    %Message{
      data: String.replace(event.data, ~s("), ""),
      acknowledger: {__MODULE__, :ack_id, :ack_data}
    }
  end

  def ack(:ack_id, _successful, _failed) do
    :ok
  end

  defp display_quote(symbol, price) do
    IO.puts("#{symbol} - #{price}")
  end
end
