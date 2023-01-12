defmodule BitURL do
  @moduledoc """
  BitURL keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias BitURL.Repo
  alias BitURL.Link

  def create_link(link) do
    %Link{}
      |> Map.put(:bit, Link.bit())
      |> Link.changeset(link)
      |> Repo.insert()
  end
end
