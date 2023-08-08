defmodule Bonfire.Fail.Auth do
  defexception [:code, :message, :status, plug_status: 401]

  @impl true
  def exception(value) do
    Bonfire.Fail.fail(value, nil, Bonfire.Fail.Auth)
  end
end
