defmodule BitURL.User do
  alias BitURL.Link
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string

    has_many :links, Link

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> unique_constraint(:email)
  end
end
