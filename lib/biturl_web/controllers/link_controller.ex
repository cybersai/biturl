defmodule BitURLWeb.LinkController do
  alias BitURL.Link
  use BitURLWeb, :controller

  def home(conn, _params) do
    changeset = Link.changeset(%Link{}, %{})
    render(conn, "home.html", changeset: changeset)
  end

  def analyze(conn, _params) do
    render(conn, "analyze.html")
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
