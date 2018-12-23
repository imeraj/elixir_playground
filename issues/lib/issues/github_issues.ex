defmodule Issues.GitHubIssues do
  @user_agent [{"User-agent", "Elixir deve@pragprog.com"}]
  @github_url Application.get_env(:issues, :github_url)

  def fetch(user, project) do
    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response()
  end

  defp handle_response({:ok, %{status_code: 200, body: body}}) do
    body = body |> Poison.Parser.parse!(%{})
    {:ok, body}
  end

  defp handle_response({:ok, %{status_code: _, body: body}}) do
    body = body |> Poison.Parser.parse!(%{})
    {:error, body}
  end

  defp issues_url(user, project) do
    "#{@github_url}/repos/#{user}/#{project}/issues"
  end
end