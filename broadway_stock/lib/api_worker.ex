defmodule Api.Worker do
  use GenServer

  @name AW

  ## Client API
  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, :ok, options ++ [name: @name])
  end

  def get_quote(symbol) do
    GenServer.call(@name, {:symbol, symbol})
  end

  ## Server Callbacks
  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:symbol, symbol}, _from, state) do
    case quote_of(symbol) do
      {:ok, price} ->
        {:reply, "$#{Float.to_string(price, decimals: 2)}", state}

      {:error, message} ->
        {:reply, message, state}

      _ ->
        {:reply, :error, state}
    end
  end

  ## Helper Functions
  defp apikey do
    "5W5AS9YD0O2S8KOT"
  end

  defp url_for(symbol) do
    "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=#{symbol}&apikey=#{apikey()}"
  end

  defp quote_of(symbol) do
    result =
      url_for(symbol)
      |> HTTPoison.get()
      |> parse_response
  end

  defp get_price(json) do
    try do
      price = json["Global Quote"]["05. price"] |> String.to_float() |> Float.round(2)
      {:ok, price}
    rescue
      _ -> :error
    end
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> JSON.decode!() |> get_price
  end

  defp parse_response({:ok, %HTTPoison.Response{body: _, status_code: _status_code}}) do
    {:error, "Symbol not found!"}
  end
end
