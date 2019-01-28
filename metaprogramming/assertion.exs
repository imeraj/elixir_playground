defmodule Assertion do
  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :tests, accumulate: true)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def run(), do: Assertion.Test.run(@tests, __MODULE__)
    end
  end

  defmacro test(description, do: test_block) do
    test_func = String.to_atom(description)
    quote do
      @tests {unquote(test_func), unquote(description)}
      def unquote(test_func) (), do: unquote(test_block)
    end
  end

  defmacro assert({operator, _, [lhs, rhs]}) do
    quote bind_quoted: [operator: operator, lhs: lhs, rhs: rhs] do
      Assertion.Test.assert(operator, lhs, rhs)
    end
  end
end

defmodule Assertion.Test do
  def run(tests, module) do
    Enum.each(tests, fn {test_func, description} ->
      case apply(module, test_func, []) do
        :ok             -> IO.write "."
        {:fail, reason} -> IO.puts """

        ===============================================
        FAILURE: #{description}
        ===============================================
        #{reason}
        """
      end
    end)
  end

  def assert(:==, lhs, rhs) when lhs == rhs do
    :ok
  end
  def assert(:==, lhs, rhs) do
    {:fail,  """
      FAILURE:
      Expected:          #{lhs}
      to be equal to:    #{rhs}
      """
    }
  end

  def assert(:>, lhs, rhs) when lhs > rhs do
    :ok
  end
  def assert(:>, lhs, rhs) do
    {:fail, """
      FAILURE:
      Expected:           #{lhs}
      to be greated than: #{rhs}
      """
    }
  end
end

defmodule MathTest do
  use Assertion

  test "integers can be added and subtracted" do
    assert 2 + 3 == 5
    assert 5 - 5 == 10
  end

  test "integers can be multiplied and divided" do
    assert 10 / 2 == 50
    assert 5 * 5 == 20
  end
end
