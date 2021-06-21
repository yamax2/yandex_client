# frozen_string_literal: true

module YandexClient
  module ErrorHandler
    def error_for_response(response)
      msg = response.body.empty? ? response.status.to_s : response.body.to_s
      err =
        case response.code
        when 404
          NotFoundError.new(msg, http_code: 404)
        else
          ApiRequestError.new(msg, http_code: response.code)
        end

      raise err
    end
  end
end
