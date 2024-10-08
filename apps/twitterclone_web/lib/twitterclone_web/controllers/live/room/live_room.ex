defmodule TwittercloneWeb.LiveRoom do
  use TwittercloneWeb, :live_view
  require Logger

  alias Twitterclone.RoomContext.RoomConnection
  alias Twitterclone.RoomContext
  alias Twitterclone.RoomContext.Message

  @messages_per_page 15

  @impl true
  def mount(%{"room_id" => room_id}, session, socket) do
    {:ok, user, _idk} = Guardian.resource_from_token(TwittercloneWeb.Guardian, session["guardian_default_token"])
    {:ok, room} = RoomContext.get_room(room_id)
    {:ok, messages} = RoomContext.get_room_paginated(room.id, 0, 15)
    topic = "room" <> room_id
    if connected?(socket), do: TwittercloneWeb.Endpoint.subscribe(topic)
    #RoomContext.remove_newmsg(room_id, user.user_id)
    TwittercloneWeb.Presence.track(self(), topic, user.user_id, %{})
    {:ok, assign(socket,
            room: room,
            topic: topic,
            messages: messages |> Enum.sort_by(fn(p) -> p.inserted_at end) |> RoomContext.put_show_time,
            user: user.user_id,
            replymsg: [],
            page: 0,
            page_end: false,
            messageForm: ""
            )}
  end

  defp show_time([]), do: []

  defp show_time(messages) do
    timeids = messages
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [x, y] -> if(NaiveDateTime.diff(x.inserted_at, y.inserted_at) > 600 || x.user_id != y.user_id , do: x.id) end) # show time if message is 600 sec apart = 10 min
      |> Enum.filter(& !is_nil(&1))
    case timeids do
      [] -> [Enum.at(messages, 0).id]
      [id] -> [id]
      ids -> [ Enum.at(messages, 0).id | ids]
    end
  end



  @impl true
  def handle_event("click-message", %{"id" => id, "message" => message, "userid" => userid}, socket) do
    {:noreply, assign(socket, replymsg: id, replymsgtext: message, replymsguser: userid )}
  end

  @impl true
  def handle_event("cancel-reply", _ , socket) do
    {:noreply, assign(socket, replymsg: [])}
  end

  @impl true
  def handle_event("load-messages", _params, socket) do
    if socket.assigns.page_end do
      {:noreply, socket}
    else
      assigns = socket.assigns
      next_page = assigns.page + 1
      room_id = socket.assigns.room.id
      {:ok, messages} = RoomContext.get_room_paginated(room_id, next_page, @messages_per_page)
      page_end = Enum.count(messages) != @messages_per_page
      #Logger.info "#{Enum.count(messages)}, #{@messages_per_page}"
      allmsgs = RoomContext.put_show_time(Enum.dedup(messages ++ socket.assigns.messages))
      {:noreply, socket
        |> assign(page: next_page)
        |> assign(messages: allmsgs)
        |> assign(page_end: page_end)
      }
    end
  end

  @impl true
  def handle_info(%{event: "new-message", payload: message}, socket) do
    prev_msg = Enum.at(socket.assigns.messages, -1)
    msg = if prev_msg == nil do
      %{message | showtime: true, showprof: true}
    else
      %{message | showtime: RoomContext.compare_msg_time(message, prev_msg), showprof: RoomContext.compare_msg_prof(message, prev_msg)}
    end
    #IO.inspect(msg)
    {:noreply, assign(socket,  messages: socket.assigns.messages ++ [msg])}
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: %{joins: _joins, leaves: _leaves}}, socket) do
    {:noreply, socket}
  end



  @impl true
  def handle_event("submit_message", %{"chat" => %{"message" => message}} = chat, socket) do
    user_id = socket.assigns.user
    room_id = socket.assigns.room.id
    replymsg = socket.assigns.replymsg
    IO.inspect(chat)
    {:ok, newmsg} = RoomContext.create_message(user_id, room_id, message, replymsg)
    newmsg = Twitterclone.Repo.preload(newmsg, [:replyto, :user])
    TwittercloneWeb.Endpoint.broadcast(socket.assigns.topic, "new-message", newmsg)
    {:noreply, assign(socket, messageForm: "", replymsg: [])}
  end

  @impl true
  def handle_event("form_update", %{"chat" => %{"message" => message}} = chat, socket) do
    IO.inspect(chat)
    {:noreply, assign(socket, messageForm: message)}
  end


end
