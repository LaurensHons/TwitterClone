defmodule Twitterclone.UserContext.User do
  use Ecto.Schema
  import Ecto.Changeset
  require Logger

  @acceptable_roles ["Admin", "Manager", "User"]

  @primary_key {:user_id, :string, []}
  schema "users" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true
    field :passwordHash, :string
    field :role, :string, default: "User"
    field :picture_url, :string, default: "/images/default_user_pic.png"
    has_many :twats, Twitterclone.TwatContext.Twat, foreign_key: :user_id
    has_many :oauth_users, Twitterclone.UserContext.OauthUser, foreign_key: :user_id
    many_to_many  :following,
                  Twitterclone.UserContext.User,
                  join_through: Twitterclone.FollowerContext.Follower,
                  join_keys: [follower_id: :user_id, user_id: :user_id]


    many_to_many  :followers,
                  Twitterclone.UserContext.User,
                  join_through: Twitterclone.FollowerContext.Follower,
                  join_keys: [user_id: :user_id, follower_id: :user_id]

    has_one :api_key, Twitterclone.UserContext.ApiKey, foreign_key: :user_id

    many_to_many :rooms,
                 Twitterclone.RoomContext.Room,
                 join_through: Twitterclone.RoomContext.RoomConnection,
                 join_keys: [user_id: :user_id, room_id: :id]



    timestamps()
  end


  def get_acceptable_roles, do: @acceptable_roles
  def get_acceptable_roles(nil), do: [List.last @acceptable_roles]

  def get_acceptable_roles(%Twitterclone.UserContext.User{} = user), do: get_acceptable_roles(user.role)

  def get_acceptable_roles(role) do
    case role do
      "User" ->
        Enum.take(@acceptable_roles, -1)
      "Manager" ->
        Enum.take(@acceptable_roles, -2)
      "Admin" ->
        @acceptable_roles
    end
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:user_id, :name, :email, :password, :role, :picture_url])
    |> validate_required([:user_id, :name, :email, :role])
    |> validate_inclusion(:role, @acceptable_roles)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:user_id, name: :users_pkey,
        message: "Username already in use.")
    |> unique_constraint(:user_id, name: :unique_user_id_index,
        message: "Username already in use.")
    |> unique_constraint(:email, name: :unique_email_index,
        message: "E-mail already in use.")
    |> validate_confirmation(:password, message: "Password confirmation does not match password")
    |> put_password_hash()
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, passwordHash: Pbkdf2.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset

end
