require 'yandex_photo_storage/version'

module YandexPhotoStorage
  Config = Struct.new(:api_key, :api_secret)

  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield config
  end
end
