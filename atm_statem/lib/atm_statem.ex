defmodule AtmStatem do
  @behaviour :gen_statem

  @name :atm_statem

  @idle_message "Please insert card"
  @pin_message "Please enter PIN"
  @cash_message "Insert cash amount"

  def callback_mode, do: :state_functions

  # APIs
  def start, do: :gen_statem.start({:local, @name}, __MODULE__, [], [])

  def stop, do: :gen_statem.stop(@name)

  def message, do: :gen_statem.call(@name, :message)

  def insert_card, do: :gen_statem.call(@name, :insert_card)

  def insert_pin(pin) when is_binary(pin) do
    case correct_pin?(pin) do
      true -> :gen_statem.call(@name, :insert_correct_pin)
      false -> :gen_statem.call(@name, :insert_wrong_pin)
    end
  end

  def insert_amount(_amount), do: :gen_statem.call(@name, :insert_amount)

  # Mandatory callbacks
  def init([]), do: {:ok, :idle, @idle_message}

  def terminate(reason, _state, _data),
      do: IO.inspect("#{@name} terminated with reason - #{reason}")

  # state callbacks
  def idle({:call, from}, :insert_card, _data),
      do: {:next_state, :pin, @pin_message, [{:reply, from, :pin}]}

  def idle(event_type, event_content, data), do: handle_event(event_type, event_content, data)

  def pin({:call, from}, :insert_correct_pin, _data),
      do: {:next_state, :cash, @cash_message, [{:reply, from, :cash}]}

  def pin({:call, from}, :insert_wrong_pin, _data),
      do: {:next_state, :idle, @idle_message, [{:reply, from, :idle}]}

  def pin(event_type, event_content, data),
      do: handle_event(event_type, event_content, data)

  def cash({:call, from}, :insert_amount, _data),
      do: {:next_state, :idle, @idle_message, [{:reply, from, :idle}]}

  def cash(event_type, event_content, data),
      do: handle_event(event_type, event_content, data)

  # internal functions
  defp handle_event({:call, from}, :message, data),
       do: {:keep_state, data, [{:reply, from, data}]}

  defp handle_event({:call, from}, _, data),
       do: {:keep_state, data, [{:reply, from, data}]}

  defp correct_pin?(pin), do: !String.starts_with?(pin, "0")
end
