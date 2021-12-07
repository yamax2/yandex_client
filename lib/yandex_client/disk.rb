# frozen_string_literal: true

require 'json'

module YandexClient
  # https://yandex.ru/dev/disk/api/reference/capacity.html
  # https://yandex.ru/dev/disk/api/reference/content.html
  # https://yandex.ru/dev/disk/api/reference/move.html
  #
  # YandexClient::Disk[access_token].info
  # YandexClient::Disk[access_token].download_url('path/to/file')
  # YandexClient::Disk[access_token].download_url('path/to/file', overwrite: false)
  class Disk
    include Configurable
    include ErrorHandler

    ACTION_URL = 'https://cloud-api.yandex.net'

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
      process_response(
        with_config.get("#{ACTION_URL}/v1/disk/", headers: auth_headers)
      )
    end

    def download_url(path)
      url = URI.parse(ACTION_URL).tap do |uri|
        uri.path = '/v1/disk/resources/download'
        uri.query = URI.encode_www_form(path: path)
      end

      process_response(
        with_config.get(url, headers: auth_headers)
      ).fetch(:href)
    end

    def upload_url(path, overwrite: false)
      url = URI.parse(ACTION_URL).tap do |uri|
        uri.path = '/v1/disk/resources/upload'
        uri.query = URI.encode_www_form(path: path, overwrite: overwrite)
      end

      process_response(
        with_config.get(url, headers: auth_headers)
      ).fetch(:href)
    end

    def move(from, to, overwrite: false)
      url = URI.parse(ACTION_URL).tap do |uri|
        uri.path = '/v1/disk/resources/move'
        uri.query = URI.encode_www_form(from: from, path: to, overwrite: overwrite)
      end

      process_response(
        with_config.post(url, headers: auth_headers)
      ).fetch(:href)
    end

    private

    def auth_headers
      {Authorization: "OAuth #{@token}"}
    end

    def process_response(response)
      return JSON.parse(response.body, symbolize_names: true) if response.status.success?

      error_for_response(response)
    end
  end
end
