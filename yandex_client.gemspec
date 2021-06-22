# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yandex_client/version'

Gem::Specification.new do |spec|
  spec.name          = 'yandex_client'
  spec.version       = YandexClient::VERSION
  spec.authors       = ['Maxim Tretyakov']
  spec.email         = ['max@tretyakov-ma.ru']

  spec.summary       = 'Yandex Client'
  spec.description   = 'Allows to use yandex disk as webdav nodes'
  spec.homepage      = 'https://github.com/yamax2/yandex_client'
  spec.license       = 'MIT'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'http'
  spec.add_runtime_dependency 'ox'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '>= 10'
  spec.add_development_dependency 'rspec', '>= 3.0'
  spec.add_development_dependency 'simplecov', '>= 0.9'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'

  spec.required_ruby_version = '>= 2.4'
end
