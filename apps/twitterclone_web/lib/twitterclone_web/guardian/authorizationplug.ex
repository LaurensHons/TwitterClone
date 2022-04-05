defmodule TwittercloneWeb.Plugs.AuthorizationPlug do
  import Plug.Conn
  alias Twitterclone.UserContext.User
  alias Phoenix.Controller

  def init(options), do: options

  def call(%{private: %{guardian_default_resource: %User{} = u}} = conn, roles) do
    conn
    |> grant_access(u.role in roles)
  end

  def call(conn, _), do: grant_access(conn, false) # user not found so no authorization

  def grant_access(conn, true), do: conn  # role is in accepted roles

  def grant_access(conn, false) do        # role is not in accepted roles
    conn
    |> Controller.put_flash(:error, "Unauthorized access")
    |> Controller.redirect(to: "/")
    |> halt
  end
end