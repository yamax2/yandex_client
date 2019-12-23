# frozen_string_literal: true

module YandexClient
  module Passport
    # https://tech.yandex.ru/passport/doc/dg/reference/request-docpage/
    #
    # Example:
    #   client = YandexClient::Passport::Client.new(access_token: Token.first.access_token)
    #   client.info
    class Client < ::YandexClient::Client
      ACTION_URL = 'https://login.yandex.ru/info'
      ACTIONS = %i[info].freeze

      # action - info
      def initialize(access_token:)
        @access_token = access_token
      end

      private

      def http(_request_uri)
        @http ||= super
      end

      def request_uri(_params)
        @request_uri ||= URI.parse(ACTION_URL)
      end

      def request_headers(_params)
        {
          Authorization: "Bearer #{@access_token}"
        }
      end
    end
  end
end
