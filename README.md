# Papelillo

[![Docs](https://img.shields.io/badge/hex-docs-blue)](https://wois.hexdocs.pm/papelillo/)

Papelillo is a library to wrap and manage mailing lists, so you can create/update/delete mailing list and subscribe/unsubscribe members to these lists.

You only need to set your provider's credentials in the config file and start to manage your mailing list without configure http calls, ensure urls or dealing with tricky configurations. Use your time in the business logic of your app.

With Papelillo you can separate in other layer the management of the mailing, so if you decide change the provider or use the implementation for multiple apps you don't need to change your core code.

-----
## Supported Providers

[x] Mailgun: Papelillo.Providers.Mailgun

[ ] Gmail

[ ] Mailchimp

-----
## Installation

The package can be installed by adding `papelillo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    ...other,
    {:papelillo, "~> 0.2.1"},
    ...other
  ]
end
```

-----
## Configurations

* config.exs

```elixir
config :your_app,
    ...,
    mix_env: System.get_env("MIX_ENV")

...

config :your_app, YourApp.MailingList,
  provider: Papelillo.Providers.Mailgun,
  api_key: System.get_env("MAILGUN_API_KEY"),
  domain: System.get_env("MAILGUN_LIST_DOMAIN", "domain.xyz"),
  base_url: System.get_env("MAILGUN_BASE_URL", "https://api.eu.mailgun.net/v3")

```

* test.exs

```elixir
config :your_app,
    ...,
    mix_env: :test

...

config :your_app, YourApp.MailingList,
  http_client: HTTPoisonMock #If you want to simulate custom http responses

```

-----
## Usage

We recommend to create a module that implements your business logic and consume the functionality of the library.

```elixir
defmodule YourApp.MailingList do
  use Papelillo.MailerList, otp_app: :your_app
  
  def some_action_create(some_params) do
    ### Some code and business logic
    create(name, description, address)
    |> handle_response() 
  end
```

* By default Papelillo will try to add the domain configured in configuration's files to the address, but if the value of address is a email valid format then will use that.

-----

## Testing

By default Papelillo have a happy path test, if you want to customise your tests scenarios you can override `http_client` with your own in your Mock module in your test configuration file.

If you don't set the http_client key in the config, the library uses a http_mock that simulates always right responses from the provider.

-----

## License
Licensed under [MIT license](LICENSE)

-----

## PS
If you found this library useful, dont forget to star it (on github) =)

![GitHub stars](https://img.shields.io/github/stars/wois-org/papelillo?style=social)