defmodule SpotifyControllerV2.AlbumTableRenderer do
  use Phoenix.HTML

  def renderAlbumTable(conn, results, className) do
    albumTable = Enum.reduce(results, [albumTableHeader(className)], fn elem, acc -> [acc | albumTableRow(conn, elem, className)] end)
    content_tag(:table, albumTable)
  end

  defp albumTableHeader(className) do
    content_tag(:tr, [
      content_tag(:td,
        content_tag(:h4, "Cover", class: className)
      ),
      content_tag(:td,
        content_tag(:h4, "Album", class: className)
      ),
      content_tag(:td,
        content_tag(:h4, "Type", class: className)
      ),
      content_tag(:td,
        content_tag(:h4, "Artists", class: className)
      )
    ])
  end

  defp albumTableRow(conn, album, className) do
    content_tag(:tr, [
      content_tag(:td,
        content_tag(:a, img_tag(album.miniCoverUrl), [href: "/album?id=" <> album.albumId, class: className])
      ),
      content_tag(:td,
        content_tag(:a, album.albumName, [href: "/album?id=" <> album.albumId, class: className])
      ),
      content_tag(:td,
        content_tag(:p, album.albumType, class: className)
      ),
      content_tag(:td,
        SpotifyControllerV2.MiscRenderer.renderArtistList(album.artists, className)
      )
    ])
  end
end