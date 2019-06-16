lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yandex_photo_storage/version'

Gem::Specification.new do |spec|
  spec.name          = 'yandex_photo_storage'
  spec.version       = YandexPhotoStorage::VERSION
  spec.authors       = ['Maxim Tretyakov']
  spec.email         = ['max@tretyakov-ma.ru']

  spec.summary       = %q{Yandex Photo Storage}
  spec.description   = %q{Allows to use yandex disk as webdav nodes}
  spec.homepage      = 'https://github.com/yamax2/yandex_photo_storage'
  spec.license       = 'MIT'

  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'ox'
  spec.add_development_dependency 'rails', '>= 5.2', '< 6'

  spec.add_development_dependency 'appraisal', '>= 1.0.2'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'combustion', '>= 0.9.1'
  spec.add_development_dependency 'factory_bot_rails'
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'pg'
  spec.add_development_dependency 'rake', '>= 10'
  spec.add_development_dependency 'rspec', '>= 3.0'
  spec.add_development_dependency 'rspec-rails', '>= 3.7'
  spec.add_development_dependency 'shoulda-matchers'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'
end
