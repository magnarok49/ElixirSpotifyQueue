# SpotifyControllerV2

A few notes about intended use:
  * In a private setting, preferably running spotify on the same host as the application.
  * For the queue to work as intended, you will need to turn off shuffle and repeat.
  * I have no clue what happens when the queue runs out of songs, IE when you reach the bottom of the playlist.
  * This entire application is probably fraught with security gaps, enjoy finding them, and do let me know @magnarok49 on github.
  * When authenticating, there is set a distressing amount of scopes of access, this could probably be reduced to a few.
  * There is a watchdog set when authenticating, which tries to use a refresh token in order to renew an access token.
  * * This functionality has never been tested, so if you find the application unexpectedly fails after one hour, that would be why.

I realise that this application is literally a wrapper for spotify, 
only being able to add songs to a single playlist, but I had fun making it, so sod off. 

To start your fantastic spotify app:

  * Install dependencies with `mix deps.get`
  * Set up postgres! Start a postgres server somewhere, add postgres (admin) credentials to **/config/dev.exs**
  * Create an app in [spotifys API](https://developer.spotify.com/dashboard), set id and secret in **/config/dev.exs**
  * Add `https://www.spotifytester.com/authredirect` as a valid redirection url in your spotify app in the developer dashboard.
  * Choose (or create) a spotify playlist to server as a queue, then add the playlist id to **/config/dev.exs**
  * Add `127.0.0.1    www.spotifytester.com`to your **/dev/hosts** file
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Generate SSL certs `mix phx.gen.cert`
  * Add the https element in **/config/dev.exs** with `port: 443`, and `ip: {127,0,0,1}`
  * * Note that opening a socket on this port will require sudo, and is probably a massive security gap
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

If everything is running smoothly, you could add some mask of the LAN to the `ip` element of `http` in **/config/dev.exs**, 
then you should be able to use the application from any said IPs on the LAN, by accessing `http://<host-ip>:4000`

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

