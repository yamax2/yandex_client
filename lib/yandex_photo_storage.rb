require 'oj'
require 'yandex_photo_storage/version'

module YandexPhotoStorage
  Config = Struct.new(:api_key, :api_secret, :logger, :token_model_klass)

  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield config
  end

  autoload :Client, 'yandex_photo_storage/client'
  autoload :ApiRequestError, 'yandex_photo_storage/api_request_error'

  module Auth
    autoload :Client, 'yandex_photo_storage/auth/client'
  end

  module Passport
    autoload :Client, 'yandex_photo_storage/passport/client'
  end

  module Dav
    autoload :Client, 'yandex_photo_storage/dav/client'
  end
end
