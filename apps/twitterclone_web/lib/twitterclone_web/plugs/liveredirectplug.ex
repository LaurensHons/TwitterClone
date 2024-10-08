defmodule TwittercloneWeb.Plugs.LiveRedirectPlug do
  import Plug.Conn
  import Phoenix.Controller


  alias Twitterclone.RoomContext
  import Logger


  def init(default), do: default

  def call(conn = %{method: "GET", params: %{"room_id" => room_id}, path_info: ["rooms" | _tail]}, _args) do
    current_user = Guardian.Plug.current_resource(conn)
    case RoomContext.is_user_in_room(current_user.user_id, room_id) do
      true -> conn
      false ->
          debug "LiveRoomRedirect plug Halt"
          conn
          |> redirect(to: "/unauthorized")
          |> halt
    end
  end

  def call(conn, _args) do
    conn
  end

end
