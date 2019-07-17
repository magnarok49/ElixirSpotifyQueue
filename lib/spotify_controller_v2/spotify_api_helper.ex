defmodule SpotifyControllerV2.SpotifyApiHelper do
  use HTTPoison.Base

  @typestring "track,artist,album"
  @baseUrl "https://api.spotify.com/v1"

  @playlistId Application.get_env(:spotify_controller_v2, :secrets)[:playlist_id]
  @manageSongsUrl "/playlists/{id}/tracks"

  @artistTracksUrl "/artists/{id}/top-tracks"
  @artistAlbumsUrl "/artists/{id}/albums"
  @artistRelatedUrl "/artists/{id}/related-artists"
  @artistAlbumQuery "?country=NO&include_groups=album,single"
  
  @albumUrl "/albums/"

  def getSearchResults(queryString) do
    {:ok, res} = 
      case get!( @baseUrl <> "/search?q=" <> queryString <> "&type=" <> @typestring, 
        %{"Authorization" => "Bearer " <> SpotifyControllerV2.AuthManager.get_key()}) do
        %HTTPoison.Response{status_code: 200, headers: _header, body: body} ->
          Poison.decode(body)
        %HTTPoison.Response{status_code: code, headers: _header, body: body} ->
          {:error, code}
      end
    
    %{
      songs: songParser(res["tracks"]["items"]),
      artists: artistParser(res["artists"]["items"]),
      albums: albumParser(res["albums"]["items"])
    }
  end

  def getQueue() do
    allSongs = getQueuePlaylist()
    nowPlayingId = getPlaybackStatus()["item"]["id"]
    sliceOffAlreadyPlayed(allSongs, nowPlayingId)
  end

  def addToQueuePlaylist(songId) do
    {:ok, res} = case HTTPoison.post!(@baseUrl <> String.replace(@manageSongsUrl,"{id}",@playlistId) <> "?uris=spotify:track:" <> songId,
      [],
      %{"Authorization" => "Bearer " <> SpotifyControllerV2.AuthManager.get_key()}) 
    do
      %HTTPoison.Response{status_code: 201, headers: header, body: body} ->
        Poison.decode(body)
      %HTTPoison.Response{status_code: code, headers: header, body: body} ->
        {:error, code}
    end
  end

  def songAlreadyInQueue?(songId) do
    Enum.any?(getQueue(), fn x -> String.equivalent?(x.songId, songId) end)
  end

  def getArtist(artistId) do
    %{
      details: getArtistDetails(artistId),
      songs: getArtistSongs(artistId),
      albums: getArtistAlbums(artistId),
      related: getArtistRelatedArtists(artistId)
    }
  end

  def getAlbum(albumId) do
    {:ok, album} = 
      case get!( @baseUrl <> @albumUrl <> albumId, 
        %{"Authorization" => "Bearer " <> SpotifyControllerV2.AuthManager.get_key()}) do
        %HTTPoison.Response{status_code: 200, headers: _header, body: body} ->
          Poison.decode(body)
        %HTTPoison.Response{status_code: code, headers: _header, body: body} ->
          {:error, code}
      end
    %{
      albumName: album["name"],
      albumId: album["id"],
      artists: Enum.map(album["artists"], fn a -> %{artistName: a["name"], artistId: a["id"]} end),
      albumType: album["album_type"],
      miniCoverUrl: hd(Enum.reverse(album["images"]))["url"],
      coverUrl: hd(album["images"])["url"],
      songs: songFromAlbumParser(album["tracks"]["items"], album["name"], album["id"])
    }
  end

  # ------------------- HELPER FUNCTIONS -------------------

  defp getPlaybackStatus() do
    {:ok, res} = 
      case get!( @baseUrl <> "/me/player", %{"Authorization" => "Bearer " <> SpotifyControllerV2.AuthManager.get_key()}) do
        %HTTPoison.Response{status_code: 200, headers: _header, body: body} ->
          Poison.decode(body)
        %HTTPoison.Response{status_code: 204, headers: _header, body: body} ->
          {:ok, %{"item" => %{ "id" => "0"}}}
        %HTTPoison.Response{status_code: code, headers: _header, body: body} ->
          {:error, code}
      end
    res
  end

  defp sliceOffAlreadyPlayed(queuePlayList, nowPlayingId) do
    songIndex = Enum.find_index(queuePlayList, fn elem -> String.equivalent?(elem.songId, nowPlayingId) end)
    if songIndex == nil do
      queuePlayList
    else
      Enum.slice(queuePlayList, songIndex, 99999)
    end
  end

  defp getQueuePlaylist() do
    {:ok, playlistRes} = 
      case get!( @baseUrl <> @manageSongsUrl, 
        %{"Authorization" => "Bearer " <> SpotifyControllerV2.AuthManager.get_key()}) do
        %HTTPoison.Response{status_code: 200, headers: _header, body: body} ->
          Poison.decode(body)
        %HTTPoison.Response{status_code: code, headers: _header, body: body} ->
          {:error, code}
      end

    Enum.map(playlistRes["items"], fn elem -> elem["track"] end)
    |> songParser()
  end

  # outputs a list of maps, each map should include
  # songName, songId, artistName, artistId, albumName, albumId
  defp songParser(rawSongs) do
    Enum.map(rawSongs, 
    fn song -> 
      %{
        songName: song["name"],
        songId: song["id"],
        artists: Enum.map(song["artists"], fn a -> %{artistName: a["name"], artistId: a["id"]} end),
        albumName: song["album"]["name"],
        albumId: song["album"]["id"]
      }
    end)
  end

  defp songFromAlbumParser(rawSongs, albumName, albumId) do
    Enum.map(rawSongs, 
    fn song -> 
      %{
        songName: song["name"],
        songId: song["id"],
        artists: Enum.map(song["artists"], fn a -> %{artistName: a["name"], artistId: a["id"]} end),
        albumName: albumName,
        albumId: albumId
      }
    end)
  end

  defp albumParser(rawAlbums) do
    Enum.map(rawAlbums, 
    fn album -> 
      %{
        albumName: album["name"],
        albumId: album["id"],
        artists: Enum.map(album["artists"], fn a -> %{artistName: a["name"], artistId: a["id"]} end),
        albumType: album["album_type"],
        miniCoverUrl: hd(Enum.reverse(album["images"]))["url"],
        coverUrl: hd(album["images"])["url"]
      }
    end)
  end

  defp artistParser(rawArtists) do
    Enum.map(rawArtists, 
    fn artist -> 
      %{
        artistName: artist["name"],
        artistId: artist["id"]
      }
    end)
  end

  defp getArtistDetails(artistId) do
    {:ok, res} = 
      case get!( @baseUrl <> "/artists/" <> artistId, 
        %{"Authorization" => "Bearer " <> SpotifyControllerV2.AuthManager.get_key()}) do
        %HTTPoison.Response{status_code: 200, headers: _header, body: body} ->
          Poison.decode(body)
        %HTTPoison.Response{status_code: code, headers: _header, body: body} ->
          {:error, code}
      end
    %{ 
      artistName: res["name"]
    }
  end

  defp getArtistAlbums(artistId) do
    {:ok, res} = 
      case get!( @baseUrl <> String.replace(@artistAlbumsUrl, "{id}", artistId) <> @artistAlbumQuery, 
        %{"Authorization" => "Bearer " <> SpotifyControllerV2.AuthManager.get_key()}) do
        %HTTPoison.Response{status_code: 200, headers: _header, body: body} ->
          Poison.decode(body)
        %HTTPoison.Response{status_code: code, headers: _header, body: body} ->
          {:error, code}
      end
    albumParser(res["items"])
  end

  defp getArtistSongs(artistId) do
    {:ok, res} = 
      case get!( @baseUrl <> String.replace(@artistTracksUrl, "{id}", artistId) <> "?country=NO", 
        %{"Authorization" => "Bearer " <> SpotifyControllerV2.AuthManager.get_key()}) do
        %HTTPoison.Response{status_code: 200, headers: _header, body: body} ->
          Poison.decode(body)
        %HTTPoison.Response{status_code: code, headers: _header, body: body} ->
          {:error, code}
      end
    songParser(res["tracks"])
  end

  defp getArtistRelatedArtists(artistId) do
    {:ok, res} = 
      case get!( @baseUrl <> String.replace(@artistRelatedUrl, "{id}", artistId), 
        %{"Authorization" => "Bearer " <> SpotifyControllerV2.AuthManager.get_key()}) do
        %HTTPoison.Response{status_code: 200, headers: _header, body: body} ->
          Poison.decode(body)
        %HTTPoison.Response{status_code: code, headers: _header, body: body} ->
          {:error, code}
      end
    artistParser(res["artists"])
  end

end