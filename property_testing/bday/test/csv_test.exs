defmodule CsvTest do
  use ExUnit.Case
  use PropCheck

  alias Bday.Csv

  property "roundtrip encoding/decoding" do
    forall maps <- csv_source() do
      maps == Csv.decode(Csv.encode(maps))
    end
  end

  # unit tests
  test "one column CSV files are inherently ambiguous" do
    assert "\r\n\r\n" == Csv.encode([%{"" => ""}, %{"" => ""}])
    assert [%{"" => ""}] == Csv.decode("\r\n\r\n")
  end

  # Generators
  defp csv_source do
    let size <- pos_integer() do
      let keys <- header(size + 1) do
        list(entry(size + 1, keys))
      end
    end
  end

  defp entry(size, keys) do
    let vals <- record(size) do
      Map.new(Enum.zip(keys, vals))
    end
  end

  defp header(size), do: vector(size, name())

  defp record(size), do: vector(size, field())

  defp name, do: field()

  def field, do: oneof([unquoted_text(), quotable_text()])

  defp unquoted_text do
    let chars <- list(elements(textdata())) do
      to_string(chars)
    end
  end

  defp quotable_text do
    let chars <- list(elements('\r\n",' ++ textdata())) do
      to_string(chars)
    end
  end

  defp textdata,
    do:
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789' ++
        ':;<=>?@ !#$%&\'()*+-./[\\]^_`{|}~'
end
