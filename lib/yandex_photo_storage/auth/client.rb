require 'uri'

module YandexPhotoStorage
  module Auth
    # https://tech.yandex.ru/oauth/doc/dg/reference/refresh-client-docpage/
    # https://tech.yandex.ru/oauth/doc/dg/reference/auto-code-client-docpage/#auto-code-client__get-token
    #
    # https://oauth.yandex.ru/authorize?response_type=code&client_id=99bcbd17ad7f411694710592d978a4a2&force_confirm=false
    #
    # Example:
    #   token = Token.first
    #
    #   client = YandexPhotoStorage::Auth::Client.new
    #   client.create_token(code: '9388894')
    #   client.refresh_token(refresh_token: token.refresh_token)
    class Client < ::YandexPhotoStorage::Client
      AUTH_ACTION_URL = 'https://oauth.yandex.ru/token'.freeze

      ACTIONS = {
        create_token: 'authorization_code',
        refresh_token: 'refresh_token'
      }.freeze

      private

      def http(_request_uri)
        @http ||= super
      end

      def http_method_for_action
        METHOD_POST
      end

      def request_body(params)
        body_hash = {
          grant_type: ACTIONS.fetch(@action),
          client_id: ::YandexPhotoStorage.config.api_key,
          client_secret: ::YandexPhotoStorage.config.api_secret
        }.merge!(params)

        URI.encode_www_form(body_hash)
      end

      def request_headers(_params)
        {
          'Content-type' => 'application/x-www-form-urlencoded'
        }
      end

      def request_uri(_params)
        @request_uri ||= URI.parse(AUTH_ACTION_URL)
      end
    end
  end
end
