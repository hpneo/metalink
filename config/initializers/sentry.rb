Raven.configure do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.current_environment = ENV.fetch("SENTRY_ENVIRONMENT", Rails.env)
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end