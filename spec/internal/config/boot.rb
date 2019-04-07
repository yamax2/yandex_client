require 'rails'
require 'active_record/railtie'

require 'yandex_photo_storage'
require 'combustion'

Combustion.schema_format = :sql
Combustion.initialize! :all, database_reset: ENV['DATABASE_RESET'].to_s == 'true', load_schema: false
