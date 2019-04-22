YandexPhotoStorage.configure do |config|
  config.api_key = 'api_key'
  config.api_secret = 'api_secret'
  config.token_model_klass = ::Token

  config.logger = Logger.new(Rails.root.join('log', "yandex_api_#{::Rails.env}.log"))
end
