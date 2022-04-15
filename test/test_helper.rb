# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'minitest/reporters'
require 'minitest/autorun'
require 'rails/test_help'
require 'capybara-screenshot/minitest'
require "view_component/test_case"
require 'support/api_test_helpers'
require 'support/third_party_test_helpers'
require 'support/search_internship_offer_helpers'
require 'support/email_spam_euristics_assertions'
require 'support/organisation_form_filler'
require 'support/internship_offer_info_form_filler'
require 'support/tutor_form_filler'
require 'minitest/retry'
require 'webmock/minitest'
# these two lines should be withdrawn whenever the ChromeDriver is ok
# https://stackoverflow.com/questions/70967207/selenium-chromedriver-cannot-construct-keyevent-from-non-typeable-key/70971698#70971698
require 'webdrivers/chromedriver'
# Webdrivers::Chromedriver.required_version = '98.0.4758.80' # not working locally because of @ char
Webdrivers::Chromedriver.required_version = '99.0.4844.51' # works ok locally
# Webdrivers::Chromedriver.required_version = '89.0.4389.114' # declared on CI but not working locally with that line

Capybara.save_path = Rails.root.join('tmp/screenshots')

Minitest::Retry.use!(
  retry_count: 3,
  verbose: true,
  io: $stdout,
  exceptions_to_retry: [
    ActionView::Template::Error, # during test, sometimes fails on "unexpected token at ''", not fixable
    PG::InternalError # sometimes postgis ref system is not yet ready
  ]
)
Minitest::Reporters.use!

WebMock.disable_net_connect!(
  allow: [
    /127\.0\.0\.1/,
    /github.com/,
    /github-production-release-asset*/,
    /chromedriver\.storage\.googleapis\.com/,
    /api-adresse.data.gouv.fr/
  ]
)
class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  # Run tests in parallel with specified workers
  parallelize(workers: ENV.fetch('PARALLEL_WORKERS') { :number_of_processors })

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
