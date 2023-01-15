defmodule BitURLWeb.AuthController do
  alias BitURL.User
  alias Ueberauth.Auth.Info
  alias Ueberauth.Failure.Error
  alias Ueberauth.Failure
  alias Ueberauth.Auth
  use BitURLWeb, :controller
  plug Ueberauth

  def callback(%{assigns: %{ueberauth_auth: %Auth{info: %Info{email: email}}}} = conn, _params) do
    case BitURL.get_or_create_user(%{email: email}) do
      {:ok, %User{} = user} ->
        conn
        |> put_flash(:info, "Login Successful")
        |> put_session(:auth_id, user.id)
        |> configure_session(renew: true)
        |> redirect(to: Routes.link_path(conn, :home))
      {:error, %Ecto.Changeset{}} ->
        conn
        |> put_flash(:error, "Error creating user")
        |> redirect(to:  Routes.link_path(conn, :home))
    end
  end

  def callback(%{assigns: %{ueberauth_failure: %Failure{errors: [%Error{message: message} | _]}}} = conn, _params) do
    conn
    |> put_flash(:error, message)
    |> redirect(to:  Routes.link_path(conn, :home))
  end

  def remove(conn, _param) do
    conn
    |> put_flash(:info, "Logout Successful")
    |> clear_session()
    |> redirect(to: Routes.link_path(conn, :home))
  end
end
