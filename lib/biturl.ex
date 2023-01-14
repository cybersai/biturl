defmodule BitURL do
  @moduledoc """
  BitURL keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias BitURL.Link.Summary
  alias BitURL.Repo
  alias BitURL.Link

  def change_link(link) do
    Link.changeset(%Link{}, link)
  end

  def analyze_link(%{"url" => url}) do
    with {:ok, %HTTPoison.Response{status_code: status_code, body: body}} when status_code in 200..299 <- HTTPoison.get(url),
      {:ok, document} <- Floki.parse_document(body) do
        {:ok, %Summary{
          status_code: status_code,
          title: Floki.attribute(document, "meta[property=\"og:title\"]", "content") |> Enum.uniq() |> List.first(),
          description: Floki.attribute(document, "meta[property=\"og:description\"]", "content") |> Enum.uniq() |> List.first(),
          image: Floki.attribute(document, "meta[property=\"og:image\"]", "content") |> Enum.uniq() |> List.first()
        }}
    else
      {:ok, %HTTPoison.Response{}} -> {:error, "unsuccesful response"}
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
      {:error, reason} -> {:error, reason}
    end
  end

  def create_link(link) do
    %Link{}
      |> Map.put(:bit, Link.bit())
      |> Link.changeset(link)
      |> Repo.insert()
  end
end
