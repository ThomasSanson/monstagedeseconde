# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'activerecord-postgis-adapter' # postgis extension
gem 'pg'
gem 'rails'
gem 'turbolinks'
gem 'webpacker'

# Use Puma as the app server
gem 'bootsnap', require: false
gem 'puma'
gem 'newrelic_rpm'


# gem 'geocoder'
group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end
gem 'delayed_job_active_record'
gem "delayed_job_web"

group :development do
  gem 'foreman'
  gem 'rubocop'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'bullet'
  gem 'listen'
  gem 'web-console'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara'
  gem 'minitest-reporters'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'rails-controller-testing'
  gem 'webdrivers'
end

group :test, :development do
  gem 'factory_bot_rails'
end

group :staging do
  gem 'rest-client'
end


# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'discard'
gem 'slim-rails'

gem 'sentry-raven'

gem 'cancancan'
gem 'devise'
gem 'devise-i18n'

gem 'aasm'
gem 'kaminari'
