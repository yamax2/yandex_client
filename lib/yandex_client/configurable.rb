# frozen_string_literal: true

module YandexClient
  module Configurable
    def self.included(base)
      base.extend Forwardable
      base.def_delegator :YandexClient, :config
    end

    private

    def with_config
      req = HTTP.timeout(
        connect: config.connect_timeout,
        read: config.read_timeout,
        write: config.write_timeout
      )

      if config.logger
        req.use(logging: {logger: config.logger})
      else
        req
      end
    end
  end
end
