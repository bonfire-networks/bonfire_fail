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
  def fail(reason, extra \\ nil, struct \\ Fail)

  def fail({:error, reason}, extra, struct) do
    handle(reason, extra, struct)
  end

  def fail({:error, reason, extra}, _extra, struct) do
    handle(reason, extra, struct)
  end

  # Ecto transaction errors
  def fail({:error, _operation, reason, _changes}, extra, struct) do
    handle(reason, extra, struct)
  end

  def fail({key, extra}, _extra, struct) do
    handle(key, extra, struct)
  end

  # Other errors
  def fail(other, extra, struct) do
    handle(other, extra, struct)
  end

  # Handle Different Errors
  # -----------------------

  defp handle(reason, extra \\ nil, struct \\ Fail)

  defp handle(reason, %Ecto.Changeset{} = changeset, struct),
    do: handle(reason, changeset_message(changeset), struct)

  defp handle(name, extra, struct) when is_atom(name) do
    {status, message} = metadata(name, extra)

    return(struct, %{
      code: name,
      message: message,
      status: status
    })
  end

  defp handle(http_code, extra, struct) when is_integer(http_code) do
    {name, status, message} =
      case get_error(http_code) do
        nil ->
          {nil, http_code, extra}

        {name, message} ->
          {status, message} = metadata(name, extra)
          {name, status, message}
      end

    return(struct, %{
      code: name,
      message: message,
      status: status
    })
  end

  defp handle(message, extra, struct) when is_binary(message) do
    case Bonfire.Common.Types.maybe_to_atom(message) do
      nil ->
        status = 500

        return(struct, %{
          code: status,
          message: "#{message} #{extra}",
          status: status
        })

      code ->
        handle(code, extra, struct)
    end
  end

  defp handle(errors, _, struct) when is_list(errors) do
    Enum.map(errors, &handle(&1, nil, struct))
  end

  defp handle(%Ecto.Changeset{} = changeset, _, struct) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {err, _opts} -> err end)
    |> Enum.map(fn {k, v} ->
      return(struct, %{
        code: :validation,
        message: String.capitalize("#{k} #{v}"),
        status: 422
      })
    end)
  end

  # ... Handle other error types here ...
  defp handle(other, extra, struct) do
    error(extra, "Unhandled error type: #{inspect(other)}")
    handle(:unknown, extra, struct)
  end

  def changeset_message(%Changeset{} = changeset) do
    {_key, {message, _args}} = List.first(changeset.errors)
    String.trim(message, "\"")
  end

  defp return(struct \\ Fail, error) do
    error(error)
    struct(struct, error)
  end

  def list_errors() do
    Application.get_env(:bonfire_fail, :common_errors, [])
  end

  def list_http_errors() do
    list_errors()
    |> Enum.map(fn
      {name, {http_code, msg}} -> {http_code, {name, msg}}
    end)
  end

  def get_error(error_term) when is_atom(error_term) do
    list_errors()[error_term]
  end

  def get_error(http_code) when is_integer(http_code) do
    list_errors()
    |> Enum.find_value(fn
      {name, {^http_code, msg}} -> {name, msg}
      _ -> nil
    end)
  end

  def get_error(error_term) when is_binary(error_term) do
    case maybe_to_atom!(error_term) do
      nil -> nil
      false -> false
      error_term -> get_error(error_term)
    end
  end

  def get_error_tuple(error_term, error_applies_to \\ "") do
    case get_error(error_term) do
      {status, message} ->
        {status, show_error_msg(message, error_applies_to)}

      _ ->
        nil
    end
  end

  def get_error_msg(error_term, error_applies_to \\ "") do
    case get_error_tuple(error_term, error_applies_to) do
      {_status, message} ->
        message

      _ ->
        nil
    end
  end

  defp show_error_msg(message, extra) do
    show = String.replace(message, "%s", extra || "")

    if show == message do
      "#{show} #{extra}"
    else
      show
    end
  end

  # Build Error Metadata
  # --------------------
  def metadata(error_term, error_applies_to \\ "")

  def metadata(error_term, extra) when is_atom(error_term) do
    case get_error(error_term) do
      {status, message} ->
        {status, show_error_msg(message, extra)}

      _ ->
        error(
          extra,
          "Undefined error code (you may want to add it to `config :bonfire_fail, :common_errors`): #{inspect(error_term)}"
        )

        {422, "Error (#{error_term}) #{inspect(extra)}"}
    end
  end

  def metadata(code, extra) do
    error(extra, "Bonfire.Fail expected an atom, but got #{inspect(code)}")
    {422, "Error (#{code}) #{inspect(extra)}"}
  end

  defp maybe_to_atom!(str) when is_binary(str) do
    try do
      String.to_existing_atom(str)
    rescue
      ArgumentError -> nil
    end
  end
end

defimpl Plug.Exception, for: Bonfire.Fail do
  import Untangle

  def status(%{status: code} = _exception) do
    # info(exception, "return right code")
    code
  end

  def status(_exception) do
    500
  end

  def actions(_exception), do: []
end
