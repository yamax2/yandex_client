require 'bundler/setup'
require 'pry-byebug'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../spec/internal/config/boot', __FILE__)

require 'rspec/rails'
require 'faker'
require 'shoulda-matchers'
require 'factory_bot_rails'
require 'webmock/rspec'
require 'vcr'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.use_transactional_fixtures = true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

API_APPLICATION_KEY = 'key'.freeze
API_APPLICATION_SECRET = 'secret'.freeze

API_ACCESS_TOKEN = 'access'.freeze
API_REFRESH_TOKEN = 'refresh'.freeze

VCR.configure do |c|
  c.ignore_localhost = true
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock

  c.filter_sensitive_data('<TOKEN>') { API_ACCESS_TOKEN }
  c.filter_sensitive_data('<REFRESH_TOKEN>') { API_REFRESH_TOKEN }
  c.filter_sensitive_data('<API_SECRET_KEY>') { API_APPLICATION_SECRET }

  c.configure_rspec_metadata!
end
