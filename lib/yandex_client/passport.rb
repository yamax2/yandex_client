# frozen_string_literal: true

module YandexClient
  # https://tech.yandex.ru/passport/doc/dg/reference/request-docpage/
  #
  # Example:
  #   YandexClient::Passport::Client[Token.first.access_token].info
  class Passport
    include Configurable
    include ErrorHandler

    ACTION_URL = 'https://login.yandex.ru/info'

    attr_reader :token

    class << self
      def with_token(token)
        new(token)
      end

      alias [] with_token
    end

    def initialize(token)
      @token = token
    end

    def info
      process_response \
        with_config.get(ACTION_URL, headers: auth_headers)
    end

    private

    def auth_headers
      {Authorization: "Bearer #{@token}"}
    end

    def process_response(response)
      return JSON.parse(response.body, symbolize_names: true) if response.status.success?

      error_for_response(response)
    end
  end
end
