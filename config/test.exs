import Config

config :papelillo,
  env: "test"

import_config "#{config_env()}.exs"
