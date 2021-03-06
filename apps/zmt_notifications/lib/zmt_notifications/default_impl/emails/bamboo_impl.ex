defmodule ZMTNotifications.DefaultImpl.Emails.BambooImpl do
  @moduledoc false

  import ZMTNotifications.DefaultImpl.Emails.Guards

  alias __MODULE__.Email
  alias __MODULE__.Mailer
  alias ZMTNotifications.DefaultImpl.Emails.Impl

  @behaviour Impl

  @type email :: Impl.email()

  @impl true
  @spec send_welcome_email(email) :: :ok
  def send_welcome_email(email) when is_email(email) do
    email
    |> Email.welcome_email()
    |> Mailer.deliver_later()

    :ok
  end
end
