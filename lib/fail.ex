defmodule Bonfire.Fail do
  import Untangle
  alias __MODULE__
  alias Ecto.Changeset

  # defstruct [:code, :message, :status]
  defexception [:code, :message, :status]

  @impl true
  def exception(value) do

    # if Code.ensure_loaded?(Bonfire.Common.Config) do
    #   error(value)
    #   Bonfire.Common.Config.require_extension_config!(:bonfire_fail)
    # end

    fail(value)
  end

  # Error Tuples
  # ------------

  # Regular errors
  def fail({:error, reason}) do
    handle(reason)
  end

  def fail({:error, reason, extra}) do
    handle(reason, extra)
  end

  # Ecto transaction errors
  def fail({:error, _operation, reason, _changes}) do
    handle(reason)
  end

  # Unhandled errors
  def fail(other) do
    handle(other)
  end

  def fail(other, extra) do
    handle(other, extra)
  end

  # Handle Different Errors
  # -----------------------

  defp handle(reason, extra \\ "")

  defp handle(reason, %Ecto.Changeset{} = changeset),
    do: handle(reason, changeset_message(changeset))

  defp handle(code, extra) when is_atom(code) do
    {status, message} = metadata(code, extra)

    return(%Fail{
      code: code,
      message: message,
      status: status
    })
  end

  defp handle(status, extra) when is_integer(status) do
    return(%Fail{
      code: status,
      message: "#{extra}",
      status: status
    })
  end

  defp handle(message, extra) when is_binary(message) do
    status = 500

    return(%Fail{
      code: status,
      message: "#{message} #{extra}",
      status: status
    })
  end

  defp handle(errors, _) when is_list(errors) do
    Enum.map(errors, &handle/1)
  end

  defp handle(%Ecto.Changeset{} = changeset, _) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {err, _opts} -> err end)
    |> Enum.map(fn {k, v} ->
      return(%Fail{
        code: :validation,
        message: String.capitalize("#{k} #{v}"),
        status: 422
      })
    end)
  end

  # ... Handle other error types here ...
  defp handle(other, extra) do
    error(extra, "Unhandled error type: #{inspect(other)}")
    handle(:unknown, extra)
  end

  def changeset_message(%Changeset{} = changeset) do
    {_key, {message, _args}} = List.first(changeset.errors)
    String.trim(message, "\"")
  end

  defp return(error) do
    error(error)
    error
  end

  # Build Error Metadata
  # --------------------
  def metadata(error_term, error_applies_to \\ "")

  def metadata(error_term, extra) when is_atom(error_term) do
    common_errors = Application.get_env(:bonfire_fail, :common_errors, %{})
    error_list = Map.keys(common_errors)

    if error_term in error_list do
      {status, message} = common_errors[error_term]
      show = String.replace(message, "%s", extra)

      if show == message do
        {status, "#{show} #{extra}"}
      else
        {status, "#{show}"}
      end
    else
      error(extra, "Undefined error code (you may want to add it to `config :bonfire_fail, :common_errors`): #{inspect(error_term)}")
      {422, "Error (#{error_term}) #{inspect(extra)}"}
    end
  end

  def metadata(code, extra) do
    error(extra, "Bonfire.Fail expected an atom, but got #{inspect(code)}")
    {422, "Error (#{code}) #{inspect(extra)}"}
  end
end
