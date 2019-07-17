defmodule SpotifyControllerV2Web.Router do
  use SpotifyControllerV2Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SpotifyControllerV2Web do
    pipe_through :browser

    get "/", PageController, :index
    get "/auth", AuthController, :index
    get "/authredirect", AuthRedirectController, :index
    get "/menu", MenuController, :index
    get "/waitForAuth", WaitForAuthController, :index
    get "/search", SearchController, :index
    post "/search", SearchController, :search
    post "/api", ApiController, :addSong
    get "/queue", QueueController, :index
    get "/artist", ArtistController, :index
    get "/album", AlbumController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", SpotifyControllerV2Web do
  #   pipe_through :api
  # end
end
