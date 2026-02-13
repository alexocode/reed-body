import Config

config :body,
  ghost_url: System.get_env("GHOST_URL", "https://systemic.engineering"),
  # Format: "id:secret" from Ghost Admin API key
  ghost_admin_key: System.get_env("GHOST_ADMIN_KEY")
