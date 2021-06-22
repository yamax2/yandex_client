# frozen_string_literal: true

module YandexClient
  # https://tech.yandex.ru/oauth/doc/dg/reference/refresh-client-docpage/
  # https://tech.yandex.ru/oauth/doc/dg/reference/auto-code-client-docpage/#auto-code-client__get-token
  #
  # https://oauth.yandex.ru/authorize?response_type=code&client_id=ede5c51271164a9e833ab9119b4d3c26&force_confirm=false
  #
  # Example:
  #   token = Token.first
  #
  #   YandexClient.auth.create_token('9388894')
  #   YandexClient.auth.refresh_token(token.refresh_token)
  class Auth
    include Configurable
    include ErrorHandler

    ACTION_URL = 'https://oauth.yandex.ru/token'

    def create_token(code)
      process_response with_config.post(
        ACTION_URL,
        headers: common_headers,
        body: URI.encode_www_form(
          request_body_for('authorization_code').merge!(code: code)
        )
      )
    end

    def refresh_token(refresh_token)
      process_response with_config.post(
        ACTION_URL,
        headers: common_headers,
        body: URI.encode_www_form(
          request_body_for('refresh_token').merge!(refresh_token: refresh_token)
        )
      )
    end

    private

    def common_headers
      {'Content-type' => 'application/x-www-form-urlencoded'}
    end

    def request_body_for(grant_type)
      {
        grant_type: grant_type,
        client_id: config.api_key,
        client_secret: config.api_secret
      }
    end

    def process_response(response)
      if response.status.success?
        JSON.parse(response.body, symbolize_names: true)
      else
        error_for_response(response)
      end
    end
  end
end
