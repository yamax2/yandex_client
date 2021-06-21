# frozen_string_literal: true

require 'bundler/setup'
require 'simplecov'

SimpleCov.start do
  minimum_coverage 95.0
  add_filter 'spec/'

  add_group 'Lib', 'lib'
end

require 'pry-byebug'
require 'logger'
require 'yandex_client'
require 'webmock/rspec'
require 'vcr'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

API_APPLICATION_KEY = 'key'
API_APPLICATION_SECRET = 'secret'

API_ACCESS_TOKEN = 'access'
API_REFRESH_TOKEN = 'refresh'

VCR.configure do |c|
  c.ignore_localhost = true
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock

  c.filter_sensitive_data('<TOKEN>') { API_ACCESS_TOKEN }
  c.filter_sensitive_data('<REFRESH_TOKEN>') { API_REFRESH_TOKEN }
  c.filter_sensitive_data('<API_SECRET_KEY>') { API_APPLICATION_SECRET }

  c.configure_rspec_metadata!
end
