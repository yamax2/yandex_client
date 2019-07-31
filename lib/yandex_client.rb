require 'yandex_client/version'

module YandexClient
  Config = Struct.new(:api_key, :api_secret, :logger, :token_model_klass)

  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield config
  end

  autoload :Client, 'yandex_client/client'
  autoload :ApiRequestError, 'yandex_client/api_request_error'
  autoload :NotFoundError, 'yandex_client/not_found_error'

  module Auth
    autoload :Client, 'yandex_client/auth/client'
  end

  module Passport
    autoload :Client, 'yandex_client/passport/client'
  end

  module Dav
    autoload :Client, 'yandex_client/dav/client'
    autoload :PropfindParser, 'yandex_client/dav/propfind_parser'
  end
end
