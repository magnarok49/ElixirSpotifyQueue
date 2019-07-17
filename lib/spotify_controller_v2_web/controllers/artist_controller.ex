defmodule SpotifyControllerV2Web.ArtistController do
  use SpotifyControllerV2Web, :controller

  def index(conn, params) do
    cond do
      SpotifyControllerV2.AuthManager.is_authed?() ->
        %{details: d, songs: s, albums: a, related: r} = 
          SpotifyControllerV2.SpotifyApiHelper.getArtist(params["id"])
        render(conn,"index.html", [details: d, songs: s, albums: a, name: d.artistName, related: r])
      conn.port == 443 and conn.remote_ip == {127,0,0,1} -> 
        redirect(conn, to: "/auth")
      true ->
        redirect(conn, to: "/waitForAuth")
    end
  end
end