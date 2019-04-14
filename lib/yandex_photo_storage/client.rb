module YandexPhotoStorage
  # Base api client
  class Client
    TIMEOUT = 10

    attr_reader :method

    def initialize(method: :get)
      @method = method
    end

    def method_missing(method_name, *args, &_)
      if self.class::ACTIONS.key?(method_name)
        @action = method_name

        response = make_request
        result = JSON.parse(response.body).deep_symbolize_keys
        process_errors(response)

        result
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      self.class::ACTIONS.key?(method_name) || super
    end

    private

    def build_request_uri
      raise 'not implemented'
    end

    def http
      @http ||= Net::HTTP.new(request_uri.host, request_uri.port).tap do |http|
        http.use_ssl = true
        http.read_timeout = TIMEOUT
      end
    end

    def make_request
      request = "Net::HTTP::#{method.to_s.camelize}".constantize.new(
        request_uri.request_uri,
        request_headers
      )

      request.body = request_body

      http.start { |http| http.request(request) }
    end

    def process_errors(response)
      return if response.is_a?(Net::HTTPOK)

      raise ApiRequestError.new(
        error: result.fetch(:error),
        error_description: result.fetch(:error_description),
        code: response.code
      )
    end

    def request_body

    end

    def request_headers
      {}
    end

    def request_uri
      @request_uri ||= build_request_uri
    end
  end
end
