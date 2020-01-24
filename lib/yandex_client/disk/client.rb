# frozen_string_literal: true

module YandexClient
  module Disk
    # https://yandex.ru/dev/disk/api/reference/capacity-docpage/
    # https://yandex.ru/dev/disk/api/reference/content-docpage/
    #
    # cli = YandexClient::Dav::Client.new(access_token: access_token)
    #
    # cli.info
    # cli.download_url(path: '/my_dir')
    class Client < ::YandexClient::Client
      ACTION_URL = 'https://cloud-api.yandex.net'

      ACTIONS = {
        info: '/v1/disk/',
        download_url: '/v1/disk/resources/download'
      }.freeze

      REQUIRED_PARAMS = {
        download_url: %i[path]
      }.freeze

      def initialize(access_token:)
        @access_token = access_token
      end

      private

      def request_headers(_params)
        {
          Authorization: "OAuth #{@access_token}"
        }
      end

      def request_uri(params)
        if (required_params = REQUIRED_PARAMS[@action]) && !(missed_params = required_params - params.keys).empty?
          raise "required params not found: \"#{missed_params.join(',')}\""
        end

        URI.parse("#{ACTION_URL}#{ACTIONS.fetch(@action)}").tap do |uri|
          uri.query = URI.encode_www_form(params) unless params.empty?
        end
      end
    end
  end
end
