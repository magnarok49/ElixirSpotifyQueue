defmodule SpotifyControllerV2Web.ApiController do
  use SpotifyControllerV2Web, :controller

  def addSong(conn, params) do
    songId = params["addSongParams"]["songId"]
    if SpotifyControllerV2.SpotifyApiHelper.songAlreadyInQueue?(songId) do
      IO.puts("apicontroller.addsong, user attempted to queue song already in queue")
    else
      SpotifyControllerV2.SpotifyApiHelper.addToQueuePlaylist(songId)
    end
    redirect(conn, to: "/queue")
  end

end