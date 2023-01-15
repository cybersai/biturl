defmodule BitURL do
  @moduledoc """
  BitURL keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  import Ecto.Query, only: [from: 2]
  alias BitURL.User
  alias BitURL.Hit.Stats
  alias BitURL.Link.Summary
  alias BitURL.Repo
  alias BitURL.Link
  alias BitURL.Hit

  def change_link(%{} = link) do
    Link.changeset(%Link{}, link)
  end

  def analyze_link(%{"url" => url}) do
    with {:ok, %HTTPoison.Response{status_code: status_code, body: body}} when status_code in 200..299 <- HTTPoison.get(url),
      {:ok, document} <- Floki.parse_document(body) do
        {:ok, %Summary{
          status_code: status_code,
          title: Floki.attribute(document, "meta[property=\"og:title\"]", "content") |> List.first(),
          description: Floki.attribute(document, "meta[property=\"og:description\"]", "content") |> List.first(),
          image: Floki.attribute(document, "meta[property=\"og:image\"]", "content") |> List.first()
        }}
    else
      {:ok, %HTTPoison.Response{}} -> {:error, "unsuccesful response"}
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
      {:error, reason} -> {:error, reason}
    end
  end

  def create_link(%{} = link, user) do
    IO.inspect(if user === nil, do: %Link{}, else: Ecto.build_assoc(user, :links))
    if user === nil, do: %Link{}, else: Ecto.build_assoc(user, :links)
      |> Map.put(:bit, Link.bit())
      |> Link.changeset(link)
      |> Repo.insert()
  end

  def get_link_by_bit(bit) do
    Repo.get_by(Link, bit: bit)
  end

  def record_hit_for_link(%Link{} = link, user_agent) do
    link
      |> Ecto.build_assoc(:hits)
      |> Hit.changeset(user_agent |> extract_user_agent_info())
      |> Repo.insert()
  end

  def get_link_by_bit_with_stats(bit) do
    case Repo.get_by(Link, bit: bit) do
      nil -> {:error, "Link not found"}
      %Link{} = link -> {:ok, link, %Stats{
        devices: get_stats(link, :device),
        oss: get_stats(link, :os),
        browsers: get_stats(link, :browser)
      }}
    end
  end

  def get_or_create_user(%{email: email} = user) do
    case Repo.get_by(User, email: email) do
      %User{} = user -> {:ok, user}
      nil ->
        %User{}
        |> User.changeset(user)
        |> Repo.insert()
    end
  end

  def get_user!(id) do
    Repo.get!(User, id)
  end

  def get_links_by_user_id(user_id) do
    from(l in Link, where: l.user_id == ^user_id, order_by: [desc: :id], limit: 20)
    |> Repo.all()
  end

  defp extract_user_agent_info(nil) do
    %{
        device: "Unknown",
        os: "Unknown",
        browser: "Unknown"
    }
  end

  defp extract_user_agent_info(user_agent) do
    %{
        device: cond do
          String.contains?(user_agent, "Mobi") -> "Mobile"
          true -> "Desktop"
        end,
        os: cond do
          String.contains?(user_agent, "Android") -> "Android"
          String.contains?(user_agent, "iPhone") -> "iPhone"
          String.contains?(user_agent, "Win") -> "Windows"
          String.contains?(user_agent, "Mac") -> "Mac"
          String.contains?(user_agent, "Linux") -> "Linux"
          true -> "Unknown"
        end,
        browser: cond do
          String.contains?(user_agent, ["Opera", "OPR"]) -> "Opera"
          String.contains?(user_agent, "Firefox") -> "Firefox"
          String.contains?(user_agent, "Chrome") -> "Chrome" # Chrome always before Safari because Chrome can contain Safari
          String.contains?(user_agent, "Safari") -> "Safari"
          true -> "Unknown"
        end
    }
  end

  defp get_stats(%Link{} = link, column) when is_atom(column) do
    from(h in Hit, where: h.link_id == ^link.id, group_by: field(h, ^column), select: {field(h, ^column), count(h.id)}) |> Repo.all()
  end
end
