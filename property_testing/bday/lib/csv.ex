defmodule Bday.Csv do
  def encode([]), do: ""

  def encode(maps) do
    keys = Enum.map_join(Map.keys(hd(maps)), ",", &escape(&1))
    vals = for map <- maps, do: Enum.map_join(Map.values(map), ",", &escape(&1))
    to_string([keys, "\r\n", Enum.join(vals, "\r\n")])
  end

  def decode(""), do: []

  def decode(csv) do
    {headers, rest} = decode_header(csv, [])
    rows = decode_rows(rest)
    for row <- rows, do: Map.new(Enum.zip(headers, row))
  end

  defp escape(field) do
    if escapable(field) do
      ~s|"| <> do_escape(field) <> ~s|"|
    else
      field
    end
  end

  defp escapable(string) do
    String.contains?(string, [~s|"|, ",", "\r", "\n"])
  end

  defp do_escape(""), do: ""
  defp do_escape(~s|"| <> str), do: ~s|""| <> do_escape(str)
  defp do_escape(<<char>> <> rest), do: <<char>> <> do_escape(rest)

  defp decode_header(string, acc) do
    case decode_name(string) do
      {:ok, name, rest} -> decode_header(rest, [name | acc])
      {:done, name, rest} -> {[name | acc], rest}
    end
  end

  defp decode_rows(string) do
    case decode_row(string, []) do
      {row, ""} -> [row]
      {row, rest} -> [row | decode_rows(rest)]
    end
  end

  defp decode_row(string, acc) do
    case decode_field(string) do
      {:ok, field, rest} -> decode_row(rest, [field | acc])
      {:done, field, rest} -> {[field | acc], rest}
    end
  end

  defp decode_name(~s|"| <> rest), do: decode_quoted(rest)
  defp decode_name(string), do: decode_unquoted(string)
  defp decode_field(~s|"| <> rest), do: decode_quoted(rest)
  defp decode_field(string), do: decode_unquoted(string)
  defp decode_quoted(string), do: decode_quoted(string, "")
  defp decode_quoted(~s|"|, acc), do: {:done, acc, ""}
  defp decode_quoted(~s|"\r\n| <> rest, acc), do: {:done, acc, rest}
  defp decode_quoted(~s|",| <> rest, acc), do: {:ok, acc, rest}

  defp decode_quoted(~s|""| <> rest, acc) do
    decode_quoted(rest, acc <> ~s|"|)
  end

  defp decode_quoted(<<char>> <> rest, acc) do
    decode_quoted(rest, acc <> <<char>>)
  end

  defp decode_unquoted(string), do: decode_unquoted(string, "")
  defp decode_unquoted("", acc), do: {:done, acc, ""}
  defp decode_unquoted("\r\n" <> rest, acc), do: {:done, acc, rest}
  defp decode_unquoted("," <> rest, acc), do: {:ok, acc, rest}

  defp decode_unquoted(<<char>> <> rest, acc) do
    decode_unquoted(rest, acc <> <<char>>)
  end
end
