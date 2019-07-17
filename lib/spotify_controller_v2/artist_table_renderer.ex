defmodule SpotifyControllerV2.ArtistTableRenderer do
  use Phoenix.HTML

  def renderArtistTable(conn, results, className) do
    artistTable = Enum.reduce(results, [artistTableHeader(className)], fn elem, acc -> [acc | artistTableRow(conn, elem, className)] end)
    content_tag(:table, artistTable)
  end

  defp artistTableHeader(className) do
    content_tag(:tr, [
      content_tag(:td,
        content_tag(:h4, "Artist", class: className)
      )
    ])
  end

  defp artistTableRow(conn, artist, className) do
    content_tag(:tr, [
      content_tag(:td,
        content_tag(:a, artist.artistName, [href: "/artist?id=" <> artist.artistId, class: className])
      )
    ])
  end

end