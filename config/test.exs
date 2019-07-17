use Mix.Config

# Configure your database
config :spotify_controller_v2, SpotifyControllerV2.Repo,
  username: "postgres",
  password: "postgres",
  database: "spotify_controller_v2_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :spotify_controller_v2, SpotifyControllerV2Web.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
