Raven.configure do |config|
  config.dsn = Rails.application.credentials.sentry_dns
  config.environments = %w[ staging production ]
end