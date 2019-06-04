module YandexPhotoStorage
  module Passport
    # https://tech.yandex.ru/passport/doc/dg/reference/request-docpage/
    #
    # Example:
    #   client = YandexPhotoStorage::Passport::Client.new(access_token: Token.first.access_token)
    #   client.info
    class Client < ::YandexPhotoStorage::Client
      ACTION_URL = 'https://login.yandex.ru'.freeze
      ACTIONS = %i[info].freeze

      # action - info
      def initialize(access_token:)
        super(method: :get)

        @access_token = access_token
      end

      private

      def build_request_uri
        URI.parse("#{ACTION_URL}/#{@action}")
      end

      def request_headers
        {
          Authorization: "Bearer #{@access_token}"
        }
      end
    end
  end
end
