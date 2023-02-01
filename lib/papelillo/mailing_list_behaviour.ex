defmodule Papelillo.MailingListBehaviour do
  @moduledoc """
  Behaviour for mailing list providers integration
  """

  @type name :: String.t()
  @type description :: String.t()
  @type address :: String.t()
  @type actual_address :: String.t()
  @type list_name :: String.t()
  @type member :: String.t()
  @type config :: Keyword.t()

  @doc """
  Create a mailing list with the parameters.

  Address must be a string without blank spaces and special characters, the domain of the email address is taken from the config.exs definition.
  """
  @callback create(name, description, address, config) :: {:ok, any()} | {:error, any()}

  @callback delete(address, config) :: {:ok, any()} | {:error, any()}

  @callback update(name, description, address, actual_address, config) ::
              {:ok, any()} | {:error, any()}

  @callback subscribe(list_name, member, config) :: {:ok, any()} | {:error, any()}

  @callback unsubscribe(list_name, member, config) :: {:ok, any()} | {:error, any()}
end
