# frozen_string_literal: true

require 'digest'
require 'http'
require 'yandex_client/dav/prop_find_response'

module YandexClient
  # https://tech.yandex.ru/disk/doc/dg/reference/put-docpage/
  #
  # Chainable client:
  #
  # YandexClient::Dav[access_token]
  #   .put('1.txt', '/a/b/c/1.txt')
  #   .put(File.open('1.txt', 'rb'), '/path/to/1.txt')
  #   .put(Tempfile.new.tap { |t| t.write('say ni'); t.rewind }, '/path/to/tmp.txt')
  #   .delete('/a/b/c/1.txt')
  #   .mkcol('/a/b/c')
  #   .propfind('/a/dip.yml', depth: 0)
  #   .propfind('/a', depth: 1)
  #   .propfind.to_a
  class Dav
    include Configurable
    include ErrorHandler

    ACTION_URL = 'https://webdav.yandex.ru'
    PROPFIND_QUERY = '<?xml version="1.0" encoding="utf-8"?><propfind xmlns="DAV:"></propfind>'

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

    def put(file, dest, etag: nil, sha256: nil, size: nil)
      io = file.is_a?(String) ? File.open(file, 'rb') : file

      headers = auth_headers.merge!(
        'Etag' => etag || Digest::MD5.file(io.path),
        'Sha256' => sha256 || Digest::SHA256.file(io.path),
        'Expect' => '100-continue',
        'Content-Length' => (size || File.size(io.path)).to_s
      )

      process_response with_config.put(url_for(dest), body: io, headers: headers)
    end

    def delete(dest)
      process_response with_config.delete(
        url_for(dest),
        headers: auth_headers
      )
    end

    def mkcol(dest)
      process_response with_config.request(
        :mkcol,
        url_for(dest),
        headers: auth_headers
      )
    end

    def propfind(dest = '', depth = 1)
      headers = auth_headers.merge!(
        Depth: depth.to_s,
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Content-Length' => PROPFIND_QUERY.length
      )

      response = with_config.request(:propfind, url_for(dest), headers: headers, body: PROPFIND_QUERY)
      process_response(response)

      PropFindResponse.new(response.body.to_s)
    end

    private

    def auth_headers
      {Authorization: "OAuth #{token}"}
    end

    def url_for(dest)
      URI.parse(ACTION_URL).tap do |uri|
        path = dest
        path = "/#{path}" unless path.match?(%r{^/})

        uri.path = path
      end
    end

    def process_response(response)
      return self if response.status.success?

      error_for_response(response)
    end
  end
end
