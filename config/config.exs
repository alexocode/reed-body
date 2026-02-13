import Config

config :body,
  ghost_url: System.get_env("GHOST_API_BASE_URL", "https://systemic.engineering"),
  # Format: "id:secret" from Ghost Admin API key
  ghost_admin_key: System.get_env("GHOST_API_ADMIN_KEY")

# Import environment specific config
if File.exists?("config/#{config_env()}.exs") do
  import_config "#{config_env()}.exs"
end
