require 'oj'
require 'net/http'

module YandexClient
  # Base api client
  class Client
    TIMEOUT = 10
    METHOD_GET = 'Get'.freeze
    METHOD_POST = 'Post'.freeze

    ERRORS_BY_CODES = {
      404 => NotFoundError
    }.freeze

    def method_missing(method_name, *args, &_)
      return super unless self.class::ACTIONS.include?(method_name)

      @action = method_name
      result = nil
      response = make_request(args.last.is_a?(Hash) ? args.last : {})

      result = parse_response_body(response) unless response.body.nil? || response.body.empty?
      process_errors(response, result) unless response.is_a?(Net::HTTPSuccess)

      result
    end

    def respond_to_missing?(method_name, include_private = false)
      self.class::ACTIONS.include?(method_name) || super
    end

    private

    def http(request_uri)
      Net::HTTP.new(request_uri.host, request_uri.port).tap do |http|
        http.use_ssl = true
        http.read_timeout = TIMEOUT
        http.continue_timeout = TIMEOUT
      end
    end

    def http_method_for_action
      METHOD_GET
    end

    def log_api_request(request_uri, request, response)
      return if (logger = YandexClient.config.logger).nil?

      logger.info "#{request.method} #{request_uri} #{response.code} #{response.message}"
      logger.info "request headers: #{Oj.dump(request.to_hash)}"
      logger.info "response headers: #{Oj.dump(response.to_hash)}"
    end

    def make_request(params)
      request_uri = request_uri(params)
      @body = request_body(params)

      request = Object.const_get("Net::HTTP::#{http_method_for_action}").new(
        request_uri.request_uri,
        request_headers(params)
      )

      request.body = @body
      response = http(request_uri).start { |http| http.request(request) }

      log_api_request(request_uri, request, response)

      response
    end

    def parse_response_body(response)
      Oj.load(response.body, symbol_keys: true)
    end

    def process_errors(response, result)
      klass = ERRORS_BY_CODES.fetch(response.code.to_i, ApiRequestError)

      raise klass.new(
        error: result.is_a?(Hash) ? result&.fetch(:error) : result,
        error_description: result.is_a?(Hash) ? result&.fetch(:error_description) : nil,
        code: response.code.to_i
      )
    end

    def request_body(_params)

    end

    def request_headers(_params)
      {}
    end

    def request_uri(_params)
      raise 'not implemented'
    end
  end
end