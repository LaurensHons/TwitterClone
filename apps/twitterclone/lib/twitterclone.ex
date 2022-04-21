defmodule Twitterclone do
  @moduledoc """
  Twitterclone keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def key_gen() do
    base = 255
      |> :crypto.strong_rand_bytes()
      |> Base.encode16()
    base
  end

  def random_string_gen(len) do
    base = len
      |> :crypto.strong_rand_bytes()
      |> Base.encode16()
    base
  end

end
