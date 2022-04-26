defmodule TwittercloneWeb.UserAPIView do
  use TwittercloneWeb, :view
  alias TwittercloneWeb.UserAPIView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserAPIView, "user.json", as: :user)}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserAPIView, "user.json", as: :user)}
  end

  def render("adminshow.json", %{user: user}) do
    %{data: render_one(user, UserAPIView, "adminuser.json", as: :user)}
  end

  def render("user.json", %{user: user}) do
    %{
      user_id: user.user_id,
      name: user.name,
      email: user.email,
      role: user.role
    }
  end

  def render("adminuser.json", %{user: user}) do
    %{
      user_id: user.user_id,
      name: user.name,
      email: user.email,
      role: user.role,
      created_at: user.created_at,
      updated_at: user.updated_at,
      passwordHash: user.passwordHash,
      api_key: %{
        key: user.api_key.key
      }
    }
  end


end