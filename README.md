# Papelillo

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `papelillo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:papelillo, "~> 0.1.0"}
  ]
end
```

## Config

```elixir
config :your_app, ModuleThatImplementsPapelillo,
  provider: Papelillo.Providers.Test,
  api_key: System.get_env("MAILGUN_API_KEY"),
  domain: System.get_env("MAILGUN_LIST_DOMAIN", "domain.xyz"),
  base_url: System.get_env("MAILGUN_BASE_URL", "https://api.eu.mailgun.net/v3"),
  test_http_client: HTTPoisonMock #If you want to simulate custom http responses

```

## Usage



## Testing

By default Papelillo have a happy path test, if you want to test provider failures scenrios need to add in your test.exs file in the papelillo's section the key ":test_http_client" where the value must be the http mock that you have like HTTPoisonMock and then you can add expects in your test to simulate bad responses or something like that.

If you don't set the :test_http_client key in the config, the library uses a http_mock that simulates right responses from the provider.


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/papelillo>.

