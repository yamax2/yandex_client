# frozen_string_literal: true

require 'ox'
require 'cgi'

module YandexClient
  module Dav
    class PropfindParser
      SUCCESS_STATUS = 'HTTP/1.1 200 OK'

      PROCESSORS = {
        getcontentlength: ->(value) { value.to_i },
        resourcetype: ->(value) { value.is_a?(Hash) ? :folder : :file }
      }.freeze

      class ParseError < StandardError
      end

      def initialize(xml)
        # FIXME: dup?
        @document = Ox.load(xml.dup.force_encoding('UTF-8'), mode: :hash)
      end

      def call
        @document[:'d:multistatus'].each_with_object({}) do |node, memo|
          next if (response = node[:'d:response']).nil?

          name = CGI.unescape(response.fetch(:'d:href'))
          memo[name] = parse_node_props(response.fetch(:'d:propstat'))
        end
      end

      def self.call(xml)
        new(xml).call
      end

      private

      def parse_node_props(node)
        raise ParseError unless node.fetch(:'d:status') == SUCCESS_STATUS

        node.fetch(:'d:prop').each_with_object({}) do |(key, value), memo|
          prop_key = key.to_s.gsub(/^d:/, '').to_sym
          processor = PROCESSORS[prop_key]

          memo[prop_key] = processor.nil? ? value : processor.call(value)
        end
      end
    end
  end
end
