defmodule Employee do
  alias Bday.Csv

  if Mix.env() == :test do
    def adapt_csv_result_shim(map), do: adapt_csv_result(map)
  end

  @opaque employee :: %{required(String.t()) => term()}
  @opaque handle :: {:raw, [employee()]}

  @spec last_name(employee()) :: String.t() | nil
  def last_name(%{"last_name" => name}), do: name

  @spec first_name(employee()) :: String.t() | nil
  def first_name(%{"first_name" => name}), do: name

  @spec date_of_birth(employee()) :: Date.t()
  def date_of_birth(%{"date_of_birth" => dob}), do: dob

  @spec email(employee()) :: String.t()
  def email(%{"email" => email}), do: email

  @spec fetch(handle()) :: [employee()]
  def fetch({:raw, maps}), do: maps

  def from_csv(string) do
    {:raw,
     for map <- Csv.decode(string) do
       adapt_csv_result(map)
     end}
  end

  defp adapt_csv_result(map) do
    map =
      for {k, v} <- map, into: %{} do
        {trim(k), maybe_null(trim(v))}
      end

    dob = Map.fetch!(map, "date_of_birth")
    %{map | "date_of_birth" => parse_date(dob)}
  end

  defp trim(str), do: String.trim_leading(str, " ")

  defp maybe_null(""), do: nil
  defp maybe_null(str), do: str

  defp parse_date(str) do
    [y, m, d] = Enum.map(String.split(str, "/"), &String.to_integer(&1))
    {:ok, date} = Date.new(y, m, d)
    date
  end
end
