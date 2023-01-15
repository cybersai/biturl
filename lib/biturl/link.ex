defmodule BitURL.Link do
  defmodule Summary do
    defstruct status_code: nil, title: nil, description: nil, image: nil
  end

  use Ecto.Schema
  alias BitURL.User
  alias BitURL.Hit
  import Ecto.Changeset

  schema "links" do
    field :bit, :string
    field :url, :string

    has_many :hits, Hit
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(link, attrs) do
    link
    |> cast(attrs, [:bit, :url])
    |> validate_required([:bit, :url])
    |> unique_constraint(:bit)
  end

  def bit() do
    :crypto.strong_rand_bytes(6) |> Base.url_encode64(padding: false)
  end
end
