defmodule Issues.GitHubIssues do
  require Logger

  @user_agent [{"User-agent", "Elixir deve@pragprog.com"}]
  @github_url Application.get_env(:issues, :github_url)

  def fetch(user, project) do
    Logger.info("Fetching #{user}'s project #{project}")

    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response()
  end

  defp handle_response({:ok, %{status_code: 200, body: body}}) do
    Logger.info("Got response: status code = 200")
    Logger.debug(fn -> inspect(body) end)

    body = body |> Poison.Parser.parse!(%{})
    {:ok, body}
  end

  defp handle_response({:ok, %{status_code: status_code, body: body}}) do
    Logger.info("Got response: status code = #{status_code}")
    Logger.debug(fn -> inspect(body) end)

    body = body |> Poison.Parser.parse!(%{})
    {:error, body}
  end

  defp issues_url(user, project) do
    "#{@github_url}/repos/#{user}/#{project}/issues"
  end
end