defmodule MongodbTest do
  @moduledoc """
  https://github.com/ankhers/mongodb
  """

  @collection "mongodb_elixir_test"

  def connect do
    state = case Mongo.start_link(database: "admin") do
        {:ok, conn} ->
          cursor = Mongo.find(conn, @collection, %{})
          %{conn: conn, cursor: cursor}
        {:error, reason} ->
          IO.inspect "Mongodb error: #{inspect reason}"
    end
    state
  end

  def print_collection(%{cursor: cursor} = _state) do
    cursor
    |> Enum.to_list()
    |> IO.inspect()
  end

  def find_by_email(%{conn: conn} = _state, emails) do
    Mongo.find(conn, @collection, %{email: %{"$in" => emails}})
    |> Enum.to_list()
    |> IO.inspect()
  end

  def insert_document(%{conn: conn} = _state, document) do
	  Mongo.insert_one(conn, @collection, document)
  end
end
