defmodule BitURLWeb.LinkController do
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
      {:ok, %Link{}} ->
        conn
        |> put_flash(:info, "New link created")
        |> redirect(to: Routes.link_path(conn, :home))
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Link not created")
        |> render("home.html", changeset: changeset)
    end
  end
end
