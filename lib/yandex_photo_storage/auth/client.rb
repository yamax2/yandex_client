module YandexPhotoStorage
  module Auth
    # https://tech.yandex.ru/oauth/doc/dg/reference/refresh-client-docpage/
    # https://tech.yandex.ru/oauth/doc/dg/reference/auto-code-client-docpage/#auto-code-client__get-token
    #
    # https://oauth.yandex.ru/authorize?response_type=code&client_id=99bcbd17ad7f411694710592d978a4a2&force_confirm=false
    #
    # Example:
    #   token = Token.first
    #   YandexPhotoStorage::Auth::Client.new(refresh_token: token.refresh_token).refresh_token
    #
    #   YandexPhotoStorage::Auth::Client.new(code: '9388894').create_token
    class Client < ::YandexPhotoStorage::Client
      AUTH_ACTION_URL = 'https://oauth.yandex.ru/token'.freeze

      ACTIONS = {
        create_token: 'authorization_code',
        refresh_token: 'refresh_token'
      }.with_indifferent_access.freeze

      def initialize(params = {})
        super method: :post
        @params = params
      end

      private

      def build_request_uri
        URI.parse(AUTH_ACTION_URL)
      end

      def request_body
        {
          grant_type: ACTIONS.fetch(@action),
          client_id: ::YandexPhotoStorage.config.api_key,
          client_secret: ::YandexPhotoStorage.config.api_secret
        }.merge!(@params).to_query
      end

      def request_headers
        {
          'Content-type' => 'application/x-www-form-urlencoded'
        }
      end
    end
  end
end
