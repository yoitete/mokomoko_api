require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything (including potentially personally-identifiable information!)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  # config.cache_store = :mem_cache_store

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Use S3 for Active Storage in production
  config.active_storage.service = :amazon

  # Require AWS SDK for S3
  require "aws-sdk-s3"

  # Enable DNS rebinding protection and other `Host` header attacks.
  config.hosts = [
    "api.moko-moko.link",     # Allow requests from API domain
    "moko-moko.link",         # Allow requests from main domain
    /.*\.dkwmoj6vymm3b\.amplifyapp\.com/, # Allow requests from Amplify subdomains
    /10\.\d+\.\d+\.\d+/,      # Allow requests from 10.0.0.0/8 (Fargate private IPs)
    /172\.(1[6-9]|2[0-9]|3[0-1])\.\d+\.\d+/, # Allow requests from 172.16.0.0/12
    /192\.168\.\d+\.\d+/      # Allow requests from 192.168.0.0/16
  ]
  #
  # Skip DNS rebinding protection for the default health check endpoint.
  config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
