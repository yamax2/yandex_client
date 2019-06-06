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
    #
    # cli.propfind(name: '/a/dip.yml', depth: 0)
    # cli.propfind(name: '/a', depth: 1)
    class Client < ::YandexPhotoStorage::Client
      ACTION_URL = 'https://webdav.yandex.ru'.freeze
      PROPFIND_QUERY = '<?xml version="1.0" encoding="utf-8"?><propfind xmlns="DAV:"></propfind>'.freeze

      # actions with header processors
      ACTIONS = {
        mkcol: nil,
        delete: nil,

        put: lambda do |params|
          filename = params.fetch(:file)

          {
            Etag: Digest::MD5.file(filename).to_s,
            Sha256: Digest::SHA256.file(filename).to_s,
            Expect: '100-continue',
            'Content-Length' => File.size(filename).to_s
          }
        end,

        propfind: lambda do |params|
          headers = {
            Depth: params.fetch(:depth, 0).to_s,
            'Content-Type' => 'application/x-www-form-urlencoded'
          }

          headers['Content-Length'] = @body.length if @body.present?

          headers
        end
      }.freeze

      BODY_PROCESSORS = {
        put: ->(params) { File.read(params.fetch(:file)) },
        propfind: ->(params) { params.fetch(:depth, 0).zero? ? PROPFIND_QUERY : nil }
      }.freeze

      RESPONSE_PARSERS = {
        propfind: PropfindParser
      }.freeze

      def initialize(access_token:)
        @access_token = access_token
      end

      private

      def http_method_for_action
        @action
      end

      def parse_response_body(body)
        if (parser = RESPONSE_PARSERS[@action]).present?
          parser.call(body)
        else
          body
        end
      end

      def request_body(params)
        return unless (proc = BODY_PROCESSORS[@action]).present?

        proc.call(params)
      end

      def request_headers(params)
        proc = ACTIONS.fetch(@action)

        headers = {Authorization: "OAuth #{@access_token}"}
        headers.merge!(proc.call(params)) if proc.present?

        headers
      end

      def request_uri(params)
        URI.parse("#{ACTION_URL}#{params.fetch(:name)}")
      end
    end
  end
end
