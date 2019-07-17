# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :spotify_controller_v2,
  ecto_repos: [SpotifyControllerV2.Repo]

# Configures the endpoint
config :spotify_controller_v2, SpotifyControllerV2Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "+8qRqOrI6OesPg1FS/eU281ilYtpfiy3GpQfiazdZZBgacJrMdjoV92ux2BQAl9y",
  render_errors: [view: SpotifyControllerV2Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SpotifyControllerV2.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
