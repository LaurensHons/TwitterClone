defmodule TwittercloneWeb.CommentController do
  use TwittercloneWeb, :controller

  alias Twitterclone.CommentContext
  alias Twitterclone.CommentContext.Comment

  action_fallback TwittercloneWeb.FallbackController

  def index(conn, _params) do
    comments = CommentContext.list_comments()
    render(conn, "index.json", comments: comments)
  end

  def create(conn, %{"comment" => comment_params}) do
    with {:ok, %Comment{} = comment} <- CommentContext.create_comment(comment_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.comment_path(conn, :show, comment))
      |> render("show.json", comment: comment)
    end
  end

  def show(conn, %{"id" => id}) do
    comment = CommentContext.get_comment!(id)
    render(conn, "show.json", comment: comment)
  end

  def update(conn, %{"id" => id, "comment" => comment_params}) do
    comment = CommentContext.get_comment!(id)

    with {:ok, %Comment{} = comment} <- CommentContext.update_comment(comment, comment_params) do
      render(conn, "show.json", comment: comment)
    end
  end

  def delete(conn, %{"id" => id}) do
    comment = CommentContext.get_comment!(id)

    with {:ok, %Comment{}} <- CommentContext.delete_comment(comment) do
      send_resp(conn, :no_content, "")
    end
  end
end