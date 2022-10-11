defmodule Bonfire.Fail.Auth do
  defexception [:code, :message, :status]

  @impl true
  def exception(value) do
    Bonfire.Fail.fail(value)
  end
end
