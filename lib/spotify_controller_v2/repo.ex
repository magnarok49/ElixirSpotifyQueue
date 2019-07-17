defmodule SpotifyControllerV2.Repo do
  use Ecto.Repo,
    otp_app: :spotify_controller_v2,
    adapter: Ecto.Adapters.Postgres
end
