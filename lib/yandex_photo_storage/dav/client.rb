require 'digest'

module YandexPhotoStorage
  module Dav
    # https://tech.yandex.ru/disk/doc/dg/reference/put-docpage/
    class Client < ::YandexPhotoStorage::Client
      ACTION_URL = 'https://webdav.yandex.ru'.freeze
      ACTIONS = %i[put get mkcol delete].freeze

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
        case action
        when :put
          File.read(params.fetch(:file))
        else raise 'unreachable'
        end
      end

      def request_headers(action, params)
        case action
        when :put
          filename = params.fetch(:file)

          {
            Authorization: "OAuth #{@access_token}",
            Etag: Digest::MD5.file(filename).to_s,
            Sha256: Digest::SHA256.file(filename).to_s,
            Expect: '100-continue',
            'Content-Length' => File.size(filename).to_s
          }
        else raise 'unreachable'
        end
      end

      def request_uri(action, params)
        case action
        when :put
          URI.parse("#{ACTION_URL}#{params.fetch(:upload_file_name)}")
        else raise 'unreachable'
        end
      end
    end
  end
end
