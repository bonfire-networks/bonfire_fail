defmodule Bonfire.Fail.RuntimeConfig do
  use Bonfire.Common.Localise
  import Bonfire.Common.Modularity.DeclareHelpers

  declare_extension("Fail",
    icon: "ri:alert-fill",
    emoji: "⚠️",
    description: l("Common error messages and failure handling.")
  )

  # TODO: move undead and exception handling functionality from Bonfire.Common and Bonfire.UI.Common

  @behaviour Bonfire.Common.ConfigModule
  def config_module, do: true

  @doc """
  NOTE: you can override this default config in your app's runtime.exs, by placing similarly-named config keys below the `Bonfire.Common.Config.LoadExtensionsConfig.load_configs` line
  """
  def config do
    import Config

    # config :bonfire_fail,
    #   modularity: :disabled

    # NOTE: only add here any that are not already covered by https://hexdocs.pm/plug/Plug.Conn.Status.html#code/1-known-status-codes
    config :bonfire_fail,
      common_errors: [
        bad_request: {400, l("Invalid request.")},
        invalid_argument: {400, l("Invalid arguments passed.")},
        unknown_resource: {400, l("Unknown resource.")},
        bad_header: {400, l("Bad request: malformed header.")},
        deletion_error: {400, l("Could not delete:")},
        needs_login: {401, l("You need to log in first.")},
        password_hash_missing: {401, l("Reset your password to login.")},
        invalid_credentials:
          {401, l("We couldn't find an account with the details you provided.")},
        inactive_user:
          {403,
           l("Could not continue. You may need to get in touch with the instance moderators.")},
        spam:
          {403,
           l("Could not continue. You may need to get in touch with the instance moderators.")},
        not_permitted: {403, l("You do not have permission %s")},
        unauthorized: {403, l("You do not have permission %s")},
        # eh, anglos
        unauthorised: {403, l("You do not have permission %s")},
        no_access: {403, l("This site is by invitation only.")},
        token_expired: {403, l("This link or token has expired, please request a fresh one.")},
        already_claimed:
          {403,
           l("This link or token was already used, please request a fresh one if necessary.")},
        token_not_found: {403, l("This token was not found, please request a fresh one.")},
        user_disabled:
          {403, l("This user account is disabled. Please contact the instance administrator.")},
        email_not_confirmed: {403, l("Please confirm your email address first.")},
        not_found: {404, l("%s Not Found.")},
        user_not_found: {404, l("User not found.")},
        unknown: {500, l("Something went wrong.")},
        nil: {500, l("There was an error.")},
        nil: {503, l("The server is overloaded.")}
      ]
  end
end
