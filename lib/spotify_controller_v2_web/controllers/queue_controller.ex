defmodule SpotifyControllerV2Web.QueueController do
  use SpotifyControllerV2Web, :controller

  def index(conn, _params) do
    cond do
    SpotifyControllerV2.AuthManager.is_authed? ->
      queue = SpotifyControllerV2.SpotifyApiHelper.getQueue()
      render(conn, "index.html", [results: queue])
    conn.port == 443 and conn.remote_ip == {127,0,0,1} -> 
      redirect(conn, to: "/auth")
    true ->
      redirect(conn, to: "/waitForAuth")
    end
  end
end