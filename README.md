# BitURL

BitURL is a simple url shortener.
Before shortening the link, it checks if the link is reachable and SEO friendly.
It also help track clicks to the shortened link.
Users can login to associate links created with their account.
Login in done with google oauth

To setup locally:
  * clone repo from github `git clone https://github.com/cybersai/biturl.git`
  * change directory to project `cd biturl`
  * Install dependencies with `mix deps.get`
  * Setup your database crendetials in `config/dev.exs`
  * Setup google oauth client at [Google Develop Console](https://console.developers.google.com/home)
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
