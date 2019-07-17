defmodule SpotifyControllerV2Web.WaitForAuthController do
  use SpotifyControllerV2Web, :controller

  def index(conn, params) do
    cond do
    SpotifyControllerV2.AuthManager.is_authed? ->
      redirect(conn, to: "/menu")
    true -> 
      render(conn, "index.html")
    end
  end
end