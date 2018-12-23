defmodule Issues.CLI do
  @default_count 4

  @moduledoc """
  Handle the command line parsing and the dispatch to​
  ​the various functions that end up generating a​
  ​table of the last _n_ issues in a github project​
  """

  def run(argv) do
    argv
    |> parse_args
    |> process()
  end


  defp process(:help) do
    IO.puts """
    usage: issues <user> <project> [count | #{@default_count}]
    """
  end

  defp process({user, project, _count}) do
    Issues.GitHubIssues.fetch(user, project)
    |> decode_response()
  end


  defp decode_response({:ok, body}), do: body
  defp decode_response({:error, error}) do
    IO.puts "Error fetching from Github: #{error["message"]}"
    System.halt(2)
  end

  @doc """
  `argv` can be -h or --help, which returns :help

  Otherwise it is a github user name, project name, and (optionally) the number of
  entries to format.

  Return a tuple of `{user, project, count}`, or `:help' if help was given
  """
  def parse_args(argv) do
    OptionParser.parse(argv, switches: [help: :boolean],
              aliases: [h: :help])
    |> elem(1)
    |> args_to_internal_representation()
  end

  defp args_to_internal_representation([user, project, count]) do
    {user, project, String.to_integer(count)}
  end

  defp args_to_internal_representation([user, project]) do
    {user, project, @default_count}
  end

  defp args_to_internal_representation(_) do
    :help
  end
end