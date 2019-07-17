defmodule SpotifyControllerV2Web.PageController do
  use SpotifyControllerV2Web, :controller

  def index(conn, _params) do
    cond do
      SpotifyControllerV2.AuthManager.is_authed?() ->
        redirect(conn, to: "/menu")
      conn.port == 443 and conn.remote_ip == {127,0,0,1} -> 
        redirect(conn, to: "/auth")
      true ->
        redirect(conn, to: "/waitForAuth")
    end
  end
end
