defmodule SpotifyControllerV2Web.SearchController do
  use SpotifyControllerV2Web, :controller

  def index(conn, _params) do
    cond do
    SpotifyControllerV2.AuthManager.is_authed? ->
      render(conn, "index.html")
    conn.port == 443 and conn.remote_ip == {127,0,0,1} -> 
      redirect(conn, to: "/auth")
    true ->
      redirect(conn, to: "/waitForAuth")
    end
  end

  def search(conn, params) do
    queryString = params["searchParams"]["queryString"]
    %{songs: songs, artists: artists, albums: albums} = SpotifyControllerV2.SpotifyApiHelper.getSearchResults(queryString)
    render(conn, "searchResults.html", [query: queryString, results: songs])
  end

end