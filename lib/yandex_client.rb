# frozen_string_literal: true

require 'yandex_client/version'

require 'yandex_client/error_handler'
require 'yandex_client/configurable'

require 'yandex_client/dav'
require 'yandex_client/disk'

module YandexClient
  Config = Struct.new \
    :api_key,
    :api_secret,
    :logger,
    :read_timeout,
    :write_timeout,
    :connect_timeout

  class ApiRequestError < StandardError
    attr_reader :http_code

    def initialize(msg = nil, http_code: nil)
      if http_code
        super "#{msg}, (http code #{http_code})"
      else
        super msg
      end

      @http_code = http_code
    end
  end

  NotFoundError = Class.new(ApiRequestError)

  class << self
    def config
      @config ||= Config.new(nil, nil, nil, 120, 600, 5)
    end

    def configure
      yield config
    end
  end
end
