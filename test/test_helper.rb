ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require "minitest/reporters"
require 'minitest/autorun'
require 'rails/test_help'

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
