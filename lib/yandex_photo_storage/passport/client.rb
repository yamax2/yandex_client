module YandexPhotoStorage
  module Passport
    # https://tech.yandex.ru/passport/doc/dg/reference/request-docpage/
    # Example:
    #   YandexPhotoStorage::Passport::Client.new(access_token: Token.first.access_token).info
    class Client < ::YandexPhotoStorage::Client
      ACTION_URL = 'https://login.yandex.ru'.freeze
      ACTIONS = {info: nil}.with_indifferent_access.freeze

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
