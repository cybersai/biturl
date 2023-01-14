defmodule BitURL.Hit do
  defmodule Stats do
    defstruct devices: [], oss: [], browsers: []
  end

  use Ecto.Schema
  alias BitURL.Link
  import Ecto.Changeset

  schema "hits" do
    field :browser, :string
    field :device, :string
    field :os, :string

    belongs_to :link, Link

    timestamps()
  end

  @doc false
  def changeset(hit, attrs) do
    hit
    |> cast(attrs, [:device, :os, :browser])
    |> validate_required([:device, :os, :browser])
  end
end
