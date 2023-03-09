defmodule MailTplTest do
  use ExUnit.Case
  use PropCheck

  property "email template has first name" do
    forall employee <- employee_map() do
      String.contains?(
        MailTpl.body(employee),
        Map.fetch!(employee, "first_name")
      )
    end
  end

  defp employee_map() do
    let proplist <- [
          {"last_name", non_empty(CsvTest.field())},
          {"first_name", non_empty(CsvTest.field())},
          {"date_of_birth", date()},
          {"email", non_empty(CsvTest.field())}
        ] do
      Enum.reduce(proplist, %{}, fn {k, v}, m -> Map.put(m, k, v) end)
    end
  end

  defp date() do
    rawdate = {choose(1900, 2020), choose(1, 12), choose(1, 31)}
    # only generate valid dates
    date =
      such_that(
        {y, m, d} <- rawdate,
        when: {:error, :invalid_date} != Date.new(y, m, d)
      )

    let {y, m, d} <- date do
      {:ok, val} = Date.new(y, m, d)
      val
    end
  end
end
