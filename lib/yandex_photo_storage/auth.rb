module YandexPhotoStorage
  module Auth
    autoload :Client, 'yandex_photo_storage/auth/client'
    autoload :CreateToken, 'yandex_photo_storage/auth/create_token'
    autoload :RefreshToken, 'yandex_photo_storage/auth/refresh_token'
  end
end
