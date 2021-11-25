defmodule Naive.Trader do
  use GenServer, restart: :temporary

  require Logger

  alias Streamer.Binance.TradeEvent
  alias Decimal

  @binance_client Application.compile_env(:naive, :binance_client)

  defmodule State do
    @enforce_keys [:symbol, :buy_down_interval, :profit_interval, :tick_size, :budget, :step_size]
    defstruct [
      :symbol,
      :buy_order,
      :sell_order,
      :buy_down_interval,
      :profit_interval,
      :tick_size,
      :budget,
      :step_size
    ]
  end

  def start_link(%State{} = state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(%State{symbol: symbol} = state) do
    symbol = String.upcase(symbol)

    Logger.info("Initializing new trader for #{symbol}")

    Phoenix.PubSub.subscribe(
      Streamer.PubSub,
      "TRADE_EVENTS:#{symbol}"
    )

    {:ok, state}
  end

  def handle_info(
        %TradeEvent{price: price},
        %State{
          symbol: symbol,
          buy_order: nil,
          buy_down_interval: buy_down_interval,
          tick_size: tick_size,
          step_size: step_size,
          budget: budget
        } = state
      ) do
    quantity = calculate_quantity(budget, price, step_size)
    price = calculate_buy_price(price, buy_down_interval, tick_size)

    Logger.info("Placing BUY order for #{symbol} @ #{price}, quantity: #{quantity}")

    {:ok, %Binance.OrderResponse{} = order} =
      @binance_client.order_limit_buy(symbol, quantity, price, "GTC")

    new_state = %{state | buy_order: order}
    Naive.Leader.notify(:trader_state_updated, new_state)
    {:noreply, new_state}
  end

  def handle_info(
        %TradeEvent{
          quantity: quantity,
          buyer_order_id: _buyer_order_id
        },
        %State{
          symbol: symbol,
          buy_order: %Binance.OrderResponse{
            price: buy_price,
            order_id: _order_id,
            orig_qty: quantity
          },
          profit_interval: profit_interval,
          tick_size: tick_size
        } = state
      ) do
    sell_price = calculate_sell_price(buy_price, profit_interval, tick_size)

    Logger.info(
      "Buy order filled, placing SELL order for " <>
        "#{symbol} @ #{sell_price}), quantity: #{quantity}"
    )

    {:ok, %Binance.OrderResponse{} = order} =
      @binance_client.order_limit_sell(symbol, quantity, sell_price, "GTC")

    state = Map.delete(state, :buy_order)
    new_state = %{state | sell_order: order}
    Naive.Leader.notify(:trader_state_updated, new_state)
    {:noreply, new_state}
  end

  def handle_info(
        %TradeEvent{
          seller_order_id: order_id,
          quantity: quantity
        },
        %State{
          sell_order: %Binance.OrderResponse{
            order_id: order_id,
            orig_qty: quantity
          }
        } = state
      ) do
    Logger.info("Trade finished, trader will now exit")
    {:stop, :normal, state}
  end

  def handle_info(%TradeEvent{}, state) do
    {:noreply, state}
  end

  defp calculate_quantity(budget, price, step_size) do
    exact_target_quantity = Decimal.div(budget, price)

    Decimal.to_string(
      Decimal.mult(
        Decimal.div_int(exact_target_quantity, step_size),
        step_size
      ),
      :normal
    )
  end

  defp calculate_buy_price(current_price, buy_down_interval, tick_size) do
    exact_buy_price =
      Decimal.sub(
        current_price,
        Decimal.mult(current_price, buy_down_interval)
      )

    Decimal.to_string(
      Decimal.mult(
        Decimal.div_int(exact_buy_price, tick_size),
        tick_size
      ),
      :normal
    )
  end

  defp calculate_sell_price(buy_price, profit_interval, tick_size) do
    fee = "1.001"

    original_price = Decimal.mult(buy_price, fee)

    net_target_price =
      Decimal.mult(
        original_price,
        Decimal.add("1.0", profit_interval)
      )

    gross_target_price = Decimal.mult(net_target_price, fee)

    Decimal.to_string(
      Decimal.mult(
        Decimal.div_int(gross_target_price, tick_size),
        tick_size
      ),
      :normal
    )
  end
end
