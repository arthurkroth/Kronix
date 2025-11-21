ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "devise"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)
  # Not using fixtures; each test creates its own data.
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
