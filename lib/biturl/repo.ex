defmodule BitURL.Repo do
  use Ecto.Repo,
    otp_app: :biturl,
    adapter: Ecto.Adapters.Postgres
end
