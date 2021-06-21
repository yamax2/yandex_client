# frozen_string_literal: true

require 'ox'
require 'cgi'

module YandexClient
  class Dav
    class PropFindResponse
      include Enumerable

      SUCCESS_STATUS = 'HTTP/1.1 200 OK'

      class Item
        attr_reader :name, :created_at, :last_modified

        def initialize(name, node)
          @name = name
          @folder = node[:'d:resourcetype'].is_a?(Hash)

          load_node_data(node)
        end

        def folder?
          @folder
        end

        def file?
          !@folder
        end

        private

        def load_node_data(node)
          @created_at = node.fetch(:'d:creationdate')
          @last_modified = node.fetch(:'d:getlastmodified')

          return if folder?

          @etag = node.fetch(:'d:getetag')
          @size = node.fetch(:'d:getcontentlength').to_i

          define_singleton_method(:etag) { @etag }
          define_singleton_method(:size) { @size }
        end
      end

      def initialize(xml)
        @doc = Ox.load(
          xml.dup.force_encoding('UTF-8'),
          mode: :hash
        )
      end

      def each
        @doc[:'d:multistatus'].each do |node|
          next if (response = node[:'d:response']).nil?

          name = CGI.unescape(response.fetch(:'d:href'))
          node_data = response.fetch(:'d:propstat')

          raise ParseError unless node_data.fetch(:'d:status') == SUCCESS_STATUS

          yield Item.new(name, node_data.fetch(:'d:prop'))
        end
      end
    end
  end
end
