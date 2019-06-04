module YandexPhotoStorage
  # Base api client
  class Client
    TIMEOUT = 10

    def method_missing(method_name, *args, &_)
      return super unless self.class::ACTIONS.include?(method_name)

      result = nil
      response = make_request(method_name, args.last.is_a?(Hash) ? args.last : {})

      result = parse_response_body(response.body) if response.body.present?
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
      end
    end

    def http_method_for_action(_action)
      :get
    end

    def log_api_request(request_uri, request, response)
      return unless (logger = YandexPhotoStorage.config.logger).present?

      logger.info "#{request.method} #{request_uri} #{response.code} #{response.message}"
      logger.info "request headers: #{Oj.dump(request.to_hash, mode: :json)}"
      logger.info "response headers: #{Oj.dump(response.to_hash, mode: :json)}"
    end

    def make_request(action, params)
      request_uri = request_uri(action, params)

      request = "Net::HTTP::#{http_method_for_action(action).to_s.camelize}".constantize.new(
        request_uri.request_uri,
        request_headers(action, params)
      )

      request.body = request_body(action, params)
      response = http(request_uri).start { |http| http.request(request) }

      log_api_request(request_uri, request, response)

      response
    end

    def parse_response_body(body)
      Oj.load(body, symbol_keys: true)
    end

    def process_errors(response, result)
      raise ApiRequestError.new(
        error: result&.fetch(:error),
        error_description: result&.fetch(:error_description),
        code: response.code
      )
    end

    def request_body(_action, _params)

    end

    def request_headers(_action, _params)
      {}
    end

    def request_uri(_action, _params)
      raise 'not implemented'
    end
  end
end
