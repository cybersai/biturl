defmodule BitURL.Link do
  use Ecto.Schema
  import Ecto.Changeset

  schema "links" do
    field :bit, :string
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(link, attrs) do
    link
    |> cast(attrs, [:bit, :url])
    |> validate_required([:bit, :url])
    |> validate_length(:bit, length: 6)
    |> validate_change(:url, fn :url, url ->
      case URI.parse(url) do
        %URI{scheme: nil} -> [url: "url is invalid"]
        %URI{host: nil} -> [url: "url is invalid"]
        _ -> []
      end
    end)
  end

  def bit() do
    :crypto.strong_rand_bytes(6) |> Base.url_encode64(padding: false)
  end
end
