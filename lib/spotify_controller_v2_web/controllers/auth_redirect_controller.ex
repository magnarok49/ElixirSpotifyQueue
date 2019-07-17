defmodule SpotifyControllerV2Web.AuthRedirectController do
  use SpotifyControllerV2Web, :controller

  def index(conn, params) do
    :ok = SpotifyControllerV2.AuthManager.add_key(params["code"])
    redirect(conn, to: "/menu")
  end
end