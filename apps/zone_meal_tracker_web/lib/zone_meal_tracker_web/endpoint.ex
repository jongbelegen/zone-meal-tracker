defmodule ZoneMealTrackerWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :zone_meal_tracker_web

  alias ZoneMealTrackerWeb.Config, as: ZMTWebConfig
  alias ZoneMealTrackerWeb.Config.InvalidConfigurationError

  socket "/socket", ZoneMealTrackerWeb.UserSocket,
    websocket: true,
    longpoll: false

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :zone_meal_tracker_web,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_zone_meal_tracker_web_key",
    signing_salt: "v9PMNCmZ"

  plug ZoneMealTrackerWeb.Router

  def init(_key, config) do
    with {:ok, http_port} <- ZMTWebConfig.fetch_http_port(),
         {:ok, url_settings} <- ZMTWebConfig.fetch_url_settings(),
         {:ok, secret_key_base} <- ZMTWebConfig.fetch_secret_key_base() do
      config =
        deep_merge(config,
          http: [port: http_port],
          url: url_settings,
          secret_key_base: secret_key_base
        )

      {:ok, config}
    else
      {:error, %InvalidConfigurationError{} = error} ->
        raise error
    end
  end

  defp deep_merge(config_1, config_2) do
    # Need to wrap in a keyword list so it will deep merge
    # properly
    Config.Reader.merge([a: config_1], a: config_2)
    |> Keyword.fetch!(:a)
  end
end
