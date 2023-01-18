defmodule Papelillo.MailerList do
  @moduledoc """
  Maillist wrapper
  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      alias Papelillo.MailerList

      @otp_app Keyword.fetch!(opts, :otp_app)
      @mailer_list_config opts

      @spec create(String.t(), String.t(), String.t(), Keyword.t()) ::
              {:ok, term} | {:error, term}
      def create(name, description, address, config \\ [])

      def create(name, description, address, config) do
        MailerList.create(name, description, address, parse_config(config))
      end

      @spec update(String.t(), String.t(), String.t(), String.t(), Keyword.t()) ::
              {:ok, term} | {:error, term}
      def update(name, description, address, actual_address, config \\ [])

      def update(name, description, address, actual_address, config) do
        MailerList.update(name, description, address, actual_address, parse_config(config))
      end

      @spec delete(String.t(), Keyword.t()) :: {:ok, term} | {:error, term}
      def delete(address, config \\ [])

      def delete(address, config) do
        MailerList.delete(address, parse_config(config))
      end

      @spec subscribe(String.t(), String.t(), Keyword.t()) :: {:ok, term} | {:error, term}
      def subscribe(list_name, member, config \\ [])

      def subscribe(list_name, member, config) do
        MailerList.subscribe(list_name, member, parse_config(config))
      end

      @spec unsubscribe(String.t(), String.t(), Keyword.t()) :: {:ok, term} | {:error, term}
      def unsubscribe(list_name, member, config \\ [])

      def unsubscribe(list_name, member, config) do
        MailerList.unsubscribe(list_name, member, parse_config(config))
      end

      @doc false
      def validate_dependency do
        provider = Keyword.get(parse_config([]), :provider)
        MailerList.validate_dependency(provider)
      end

      defp parse_config(config) do
        MailerList.parse_config(@otp_app, __MODULE__, @mailer_list_config, config)
      end
    end
  end

  @doc """
  Create a mailing list with the parameters.

  Address must be a string without blank spaces and special characters, the domain of the email address is taken from the config.exs definition.
  """
  def create(name, description, address, config) do
    provider = Keyword.fetch!(config, :provider)

    address =
      Keyword.fetch(config, :domain)
      |> case do
        {:ok, domain} -> address <> "@" <> domain
        :error -> address
      end

    provider.create(name, description, address |> validate_email(), config)
  end

  @doc """
  Update a mailing list with the parameters.

  Address must be a string without blank spaces and special characters, the domain of the email address is taken from the config.exs definition.
  """
  def update(name, description, address, actual_address, config) do
    provider = Keyword.fetch!(config, :provider)

    address =
      Keyword.fetch(config, :domain)
      |> case do
        {:ok, domain} -> address <> "@" <> domain
        :error -> address
      end

    actual_address =
      Keyword.fetch(config, :domain)
      |> case do
        {:ok, domain} -> actual_address <> "@" <> domain
        :error -> actual_address
      end

    provider.update(
      name,
      description,
      address |> validate_email(),
      actual_address |> validate_email(),
      config
    )
  end

  @doc """
  Delete a mailing list with the parameters.

  Address must be a string without blank spaces and special characters, the domain of the email address is taken from the config.exs definition.
  """
  def delete(address, config) do
    provider = Keyword.fetch!(config, :provider)

    address =
      Keyword.fetch(config, :domain)
      |> case do
        {:ok, domain} -> address <> "@" <> domain
        :error -> address
      end

    provider.delete(address |> validate_email(), config)
  end

  @doc """
  Subscribe a email account to mailing list with the parameters.

  List_name must be a string without blank spaces and special characters, the domain of the email address is taken from the config.exs definition.

  Member must have complete email format
  """
  def subscribe(list_name, member, config) do
    provider = Keyword.fetch!(config, :provider)

    list_address =
      Keyword.fetch(config, :domain)
      |> case do
        {:ok, domain} -> list_name <> "@" <> domain
        :error -> list_name
      end

    provider.subscribe(list_address |> validate_email(), member |> validate_email(), config)
  end

  @doc """
  Unsubscribe a email account to mailing list with the parameters.

  List_name must be a string without blank spaces and special characters, the domain of the email address is taken from the config.exs definition.

  Member must have complete email format
  """
  def unsubscribe(list_name, member, config) do
    provider = Keyword.fetch!(config, :provider)

    list_address =
      Keyword.fetch(config, :domain)
      |> case do
        {:ok, domain} -> list_name <> "@" <> domain
        :error -> list_name
      end

    provider.unsubscribe(list_address |> validate_email(), member |> validate_email(), config)
  end

  @doc """
  Parse configs in the following order, later ones taking priority:

  1. mix configs
  2. compiled configs in MailerList module
  3. dynamic configs passed into the function
  4. system envs
  """
  def parse_config(otp_app, mailerlist, mailerlist_config, dynamic_config) do
    otp_app_env =
      if Application.get_env(otp_app, :mix_env) == :test do
        [http_client: Papelillo.Mocks.HttpMock]
        |> Keyword.merge(Application.get_env(otp_app, mailerlist, []))
      else
        Application.get_env(otp_app, mailerlist, [])
      end

    otp_app_env
    |> Keyword.merge(mailerlist_config)
    |> Keyword.merge(dynamic_config)
    |> Papelillo.MailerList.interpolate_env_vars()
  end

  @doc """
  Interpolate system environment variables in the configuration.

  This function will transform all the {:system, "ENV_VAR"} tuples into their
  respective values grabbed from the process environment.
  """
  def interpolate_env_vars(config) do
    Enum.map(config, fn
      {key, {:system, env_var}} -> {key, System.get_env(env_var)}
      {key, value} -> {key, value}
    end)
  end

  @doc false
  def validate_dependency(adapter) do
    require Logger

    with adapter when not is_nil(adapter) <- adapter,
         {:module, _} <- Code.ensure_loaded(adapter),
         true <- function_exported?(adapter, :validate_dependency, 0),
         :ok <- adapter.validate_dependency() do
      :ok
    else
      no_match when no_match in [nil, false] ->
        :ok

      {:error, :nofile} ->
        Logger.error("#{adapter} does not exist")
        :abort

      {:error, deps} when is_list(deps) ->
        Logger.error(Papelillo.MailerList.missing_deps_message(adapter, deps))
        :abort
    end
  end

  @doc false
  def missing_deps_message(adapter, deps) do
    deps =
      deps
      |> Enum.map(fn
        {lib, module} -> "#{module} from #{inspect(lib)}"
        module -> inspect(module)
      end)
      |> Enum.map(&"\n- #{&1}")

    """
    The following dependencies are required to use #{inspect(adapter)}:
    #{deps}
    """
  end

  def validate_email(email) do
    EmailChecker.Check.Format.valid?(email)
    |> case do
      true -> email
      _ -> raise "#{email} has not valid email format"
    end
  end
end
