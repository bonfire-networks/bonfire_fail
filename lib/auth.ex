defmodule Bonfire.Fail.Auth do
  @moduledoc """
  A specialized exception module for authentication-related errors in Bonfire applications.

  This module extends the Bonfire.Fail functionality with a default HTTP status code of 401 (Unauthorized).
  """

  defexception [:code, :message, :status, plug_status: 401]

  @doc """
  Creates a Bonfire.Fail.Auth exception from the given value.

  This function is called automatically when raising a Bonfire.Fail.Auth exception.
  It uses the Bonfire.Fail.fail/3 function to create the exception, but sets the struct to Bonfire.Fail.Auth.

  ## Parameters

    - value: The error value, which can be any value that Bonfire.Fail.fail/3 accepts.

  ## Examples
      
      iex> raise Bonfire.Fail.Auth, :unauthorized
      %Bonfire.Fail.Auth{code: :unauthorized, message: "You do not have permission", status: 403, plug_status: 401}

      iex> raise Bonfire.Fail.Auth, :needs_login
      %Bonfire.Fail.Auth{code: :needs_login, message: "You need to log in first.", status: 401, plug_status: 401}

  """
  @impl true
  def exception(value) do
    Bonfire.Fail.fail(value, nil, Bonfire.Fail.Auth)
  end
end
