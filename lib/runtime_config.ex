defmodule Bonfire.Fail.RuntimeConfig do
  use Bonfire.Common.Localise

  def config_module, do: true

  @doc """
  NOTE: you can override this default config in your app's runtime.exs, by placing similarly-named config keys below the `Bonfire.Common.Config.LoadExtensionsConfig.load_configs` line
  """
  def config do
    import Config

    config :bonfire_fail,
      disabled: false

    config :bonfire_fail,
      common_errors: %{
        unauthorized: {403, l("You do not have permission to %s.")},
        not_found: {404, l("%s Not Found.")},
        unauthenticated: {401, l("You need to log in first.")},
        needs_login: {401, l("You need to log in first.")},
        invalid_credentials:
          {401, l("We couldn't find an account with the details you provided.")},
        deletion_error: {400, l("Could not delete:")},
        bad_header: {400, l("Bad request: malformed header.")},
        no_access: {403, l("This site is by invitation only.")},
        token_expired: {403, l("This link or token has expired, please request a fresh one.")},
        already_claimed:
          {403,
           l("This link or token was already used, please request a fresh one if necessary.")},
        token_not_found: {403, l("This token was not found, please request a fresh one.")},
        user_disabled:
          {403, l("This user account is disabled. Please contact the instance administrator.")},
        email_not_confirmed: {403, l("Please confirm your email address first.")},
        unknown_resource: {400, l("Unknown resource.")},
        invalid_argument: {400, l("Invalid arguments passed.")},
        password_hash_missing: {401, l("Reset your password to login.")},
        user_not_found: {404, l("User not found.")},
        unknown: {500, l("Something went wrong.")}
      }
  end
end