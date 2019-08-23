defmodule ZMTConfig.DefaultImplTest do
  use ExUnit.Case, async: false

  alias ZMTConfig.Config
  alias ZMTConfig.DefaultImpl

  test "get_config/0 returns a struct with values from the environment" do
    ensure_settings_are_reset(:zmt_config, [:http_port, :url])

    port = 5400
    url_setting = [host: "foo.com"]

    Application.put_all_env(
      zmt_config: [
        http_port: port,
        url: url_setting
      ]
    )

    assert %Config{
             http_port: ^port,
             url: url_setting,
             http_uri_base: http_uri_base
           } = DefaultImpl.get_config()

    assert to_string(http_uri_base) == "http://foo.com:#{port}"
  end

  test "get_config/0 with no settings set" do
    ensure_settings_are_reset(:zmt_config, [:http_port, :url])
    Application.delete_env(:zmt_config, :http_port)
    Application.delete_env(:zmt_config, :url)

    assert %Config{
             http_port: 4000,
             url: [],
             http_uri_base: http_uri_base
           } = DefaultImpl.get_config()

    assert to_string(http_uri_base) == "http://localhost:4000"
  end

  defp ensure_settings_are_reset(otp_app, keys) when is_list(keys) do
    Enum.each(keys, &ensure_setting_is_reset(otp_app, &1))
  end

  defp ensure_setting_is_reset(otp_app, key) do
    original = Application.fetch_env(otp_app, key)

    on_exit(fn ->
      case original do
        {:ok, value} ->
          Application.put_env(otp_app, key, value)

        :error ->
          Application.delete_env(otp_app, key)
      end
    end)
  end
end