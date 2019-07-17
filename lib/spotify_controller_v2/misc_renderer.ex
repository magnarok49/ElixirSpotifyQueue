defmodule SpotifyControllerV2.MiscRenderer do
  use Phoenix.HTML

  def renderArtistList(artists, className) do
    Enum.map(artists, 
      fn a -> 
        content_tag(:a, a.artistName, [href: "/artist?id=" <> a.artistId, class: className])
      end
    )
    |> Enum.intersperse(content_tag(:p, "\n", class: className))
  end

  def renderConditionalQueueButton(conn, data, className, queueButton?) do
    if queueButton? do  
      form_for(conn, SpotifyControllerV2Web.Router.Helpers.api_path(conn, :addSong), [as: :addSongParams, class: className], 
        fn x ->
          [
            hidden_input(x, :songId, value: data.songId),
            submit("Queue")
          ]
        end
      )
    else
      content_tag(:p, "", class: className)
    end
  end
end