require 'digest'

module YandexPhotoStorage
  module Dav
    # https://tech.yandex.ru/disk/doc/dg/reference/put-docpage/
    #
    # cli = YandexPhotoStorage::Dav::Client.new(access_token: access_token)
    #
    # cli.put(file: '1.txt', name: '/a/b/c/1.txt')
    # cli.delete(name: '/a/b/c/1.txt')
    # cli.mkcol(name: '/a/b/c')
    class Client < ::YandexPhotoStorage::Client
      ACTION_URL = 'https://webdav.yandex.ru'.freeze

      ACTIONS = {
        put: lambda do |params|
          filename = params.fetch(:file)

          {
            Etag: Digest::MD5.file(filename).to_s,
            Sha256: Digest::SHA256.file(filename).to_s,
            Expect: '100-continue',
            'Content-Length' => File.size(filename).to_s
          }
        end,

        mkcol: nil,
        delete: nil
      }.freeze

      def initialize(access_token:)
        @access_token = access_token
      end

      private

      def http_method_for_action(action)
        action
      end

      def parse_response_body(_body)

      end

      def request_body(action, params)
        File.read(params.fetch(:file)) if action == :put
      end

      def request_headers(action, params)
        proc = ACTIONS.fetch(action)

        headers = {Authorization: "OAuth #{@access_token}"}
        headers.merge!(proc.call(params)) if proc.present?

        headers
      end

      def request_uri(_action, params)
        URI.parse("#{ACTION_URL}#{params.fetch(:name)}")
      end
    end
  end
end
