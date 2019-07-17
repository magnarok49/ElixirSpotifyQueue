defmodule SpotifyControllerV2.SongTableRenderer do
  use Phoenix.HTML

  def renderSongTable(conn, songs, className, queueButton?) do
    songTable = Enum.reduce(songs, [songTableHeader(className)], fn elem, acc -> [acc | songTableRow(conn, elem, className, queueButton?)] end)
    content_tag(:table, songTable)
  end

  defp songTableHeader(className) do
    content_tag(:tr, [
      content_tag(:td, 
        content_tag(:h4, "", class: className)
      ), 
      content_tag(:td,
        content_tag(:h4, "Song", class: className)
      ),
      content_tag(:td,
        content_tag(:h4, "Artists", class: className)
      ),
      content_tag(:td,
        content_tag(:h4, "Album", class: className)
      ), 
    ])
  end
  
  #outputs a tr element, for a single song
  defp songTableRow(conn, data, className, queueButton?) do
    content_tag(:tr, [
      content_tag(:td,
        SpotifyControllerV2.MiscRenderer.renderConditionalQueueButton(conn, data, className, queueButton?)
      ),
      content_tag(:td,
        content_tag(:p, data.songName, class: className)
      ),
      content_tag(:td,
        SpotifyControllerV2.MiscRenderer.renderArtistList(data.artists, className)
      ),
      content_tag(:td,
        content_tag(:a, data.albumName, [href: "/album?id=" <> data.albumId, class: className])
      )
    ])
  end
end