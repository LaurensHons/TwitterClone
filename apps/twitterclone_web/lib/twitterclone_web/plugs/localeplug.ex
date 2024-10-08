defmodule TwittercloneWeb.Plugs.Locale do
  import Plug.Conn

  #One time retrieve the locales from the config file and store it in a @locales variable.
  @locales Gettext.known_locales(TwittercloneWeb.Gettext)

  def init(default), do: default

  def call(conn, _options) do
    conn = assign(conn, :available_locales, @locales)
    case fetch_locale_from(conn) do
      nil ->
        conn #No locale is set or found in the cookies

      locale -> # A locale is set of found in the cookies, change the locale to the prefered langage and place a new cookie
      TwittercloneWeb.Gettext |> Gettext.put_locale(locale)
        conn |> put_resp_cookie("locale", locale, max_age: 365 * 24 * 60 * 60) #Put a locale cookie in the response.
    end
  end

  defp fetch_locale_from(conn) do
    (conn.params["locale"] || conn.cookies["locale"])
    |> check_locale
  end

  defp check_locale(locale) when locale in @locales, do: locale
  defp check_locale(_), do: nil
end
