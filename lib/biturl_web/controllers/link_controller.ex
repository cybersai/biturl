defmodule BitURLWeb.LinkController do
  alias BitURL.Hit.Stats
  alias BitURL.Hit
  alias BitURL.Link.Summary
  alias BitURL.Link
  use BitURLWeb, :controller

  def home(conn, _params) do
    render(conn, "home.html", changeset: BitURL.change_link(%{}))
  end

  def analyze(conn, %{"link" => link}) do
    case BitURL.analyze_link(link) do
      {:ok, %Summary{} = summary} ->
        conn
        |> render("analyze.html", changeset: BitURL.change_link(link), summary: summary)
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.link_path(conn, :home))
    end
  end

  def create(conn, %{"link" => link}) do
    case BitURL.create_link(link) do
      {:ok, %Link{} = link} ->
        conn
        |> put_flash(:info, "New link created")
        |> redirect(to: Routes.link_path(conn, :stats, link.bit))
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Link not created")
        |> render("home.html", changeset: changeset)
    end
  end

  def hit(conn, %{"bit" => bit}) do
    with %Link{} = link <- BitURL.get_link_by_bit(bit),
      user_agent <- Plug.Conn.get_req_header(conn, "user-agent") |>  List.first(),
      {:ok, %Hit{}} <- BitURL.record_hit_for_link(link, user_agent) do
        conn
        |> redirect(external: link.url)
    else
      nil ->
        conn
        |> put_flash(:error, "Link not found")
        |> redirect(to: Routes.link_path(conn, :home))
      {:error, %Ecto.Changeset{}} ->
        conn
        |> put_flash(:error, "Server error")
        |> redirect(to: Routes.link_path(conn, :home))
    end
  end

  def stats(conn, %{"bit" => bit}) do
    case BitURL.get_link_by_bit_with_stats(bit) do
      {:ok, %Link{} = link, %Stats{} = stats} ->
        conn
        |> render("show.html", link: link, stats: stats)
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.link_path(conn, :home))
    end
  end
end
