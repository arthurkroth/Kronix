ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors) if respond_to?(:parallelize)

  # Add more helper methods to be used by all tests here...
end

class ActionDispatch::IntegrationTest
  # Devise helpers for sign_in / sign_out
  include Devise::Test::IntegrationHelpers
end
