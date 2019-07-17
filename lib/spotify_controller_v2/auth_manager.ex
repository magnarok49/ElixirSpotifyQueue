defmodule SpotifyControllerV2.AuthManager do
  use GenServer

  @client_id Application.get_env(:spotify_controller_v2, :secrets)[:client_id]
  @client_secret Application.get_env(:spotify_controller_v2, :secrets)[:client_secret]

  def start_link(_some_param) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_some_param) do
    {:ok, %{authed: false, access_token: nil, refresh_token: nil}}
  end

  # api
  def is_authed? do
    GenServer.call(__MODULE__, :authed)
  end

  def add_key(key) do
    GenServer.cast(__MODULE__, {:add_key, key})
  end

  def get_key() do
    GenServer.call(__MODULE__, :get_key)
  end

  # callbacks
  def handle_call(:authed, _from, state) do
    {:reply, state.authed, state}
  end

  def handle_call(:get_key, _from, state) do
    {:reply, state.access_token, state}
  end

  def handle_cast({:add_key, key}, state) do
    # do some key validation here..
    {:ok, res} = case HTTPoison.post!("https://accounts.spotify.com/api/token",
      {:form, [{"grant_type", "authorization_code"}, {"code", key}, {"redirect_uri", "https://www.spotifytester.com/authredirect"}]},
      %{"Authorization" => "Basic " <> Base.encode64(@client_id <> ":" <> @client_secret)}) 
    do
      %HTTPoison.Response{status_code: 200, headers: header, body: body} ->
        Poison.decode(body)
      %HTTPoison.Response{status_code: code, headers: header, body: body} ->
        {:error, code}
    end
    Process.send_after(__MODULE__, :refresh_token, (res["expires_in"] - 60)*1000)
    {:noreply, %{state | authed: true, access_token: res["access_token"], refresh_token: res["refresh_token"]}}
  end

  def handle_info(:refresh_token, state) do
    # do some key validation here..
    {:ok, res} = case HTTPoison.post!("https://accounts.spotify.com/api/token",
      {:form, [{"grant_type", "refresh_token"}, {"refresh_token", state.refresh_token}]},
      %{"Authorization" => "Basic " <> Base.encode64(@client_id <> ":" <> @client_secret)}) 
    do
      %HTTPoison.Response{status_code: 200, headers: header, body: body} ->
        Poison.decode(body)
      %HTTPoison.Response{status_code: code, headers: header, body: body} ->
        {:error, code}
    end
    Process.send_after(__MODULE__, :refresh_token, (res["expires_in"] - 60)*1000)
    {:noreply, %{state | access_token: res["access_token"]}}
  end

end