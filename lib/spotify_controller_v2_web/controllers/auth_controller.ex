defmodule SpotifyControllerV2Web.AuthController do
  use SpotifyControllerV2Web, :controller
  @base_url "https://accounts.spotify.com/authorize"
  @scopes ["app-remote-control", "playlist-read-private","user-read-recently-played","playlist-modify-public","user-read-currently-playing","user-read-playback-state","user-modify-playback-state","streaming","user-top-read", "playlist-modify-private" ]
  @client_id Application.get_env(:spotify_controller_v2, :secrets)[:client_id]

  defp generate_url do
    @base_url <> "?" <> 
      Enum.join([
        "scope=" <> Enum.join(@scopes,"%20"),
        "response_type=code",
        "client_id=" <> @client_id,
        "redirect_uri=https://www.spotifytester.com/authredirect"
      ], "&")
  end

  defp pull_link_from_header(header) do
    {_key, link} = Enum.find(header,:location_missing_error,fn {key, value} -> key == "Location" end)
    link
  end

  def index(conn, _params) do
    cond do
    SpotifyControllerV2.AuthManager.is_authed? ->
      redirect(conn, to: "/menu")
    conn.port == 443 and conn.remote_ip == {127,0,0,1} ->
      case HTTPoison.get(generate_url) do
        {:ok, %HTTPoison.Response{status_code: 303, headers: header}} ->
          IO.puts("GREAT SUCCESS\n")
          redirect(conn, external: pull_link_from_header(header))
        {:ok, %HTTPoison.Response{status_code: code, headers: header}} ->
          #TODO add less terrible error handling for these two cases
          IO.puts("NOT SO GREAT SUCCESS\n")
          redirect(conn, to: "/authError")
        _catch_all -> 
          redirect(conn, to: "/authError")
      end
    true ->
      redirect(conn, to: "/waitForAuth")
    end 
  end
end