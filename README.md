[![Build Status](https://travis-ci.org/yamax2/yandex_client.svg?branch=master)](https://travis-ci.org/yamax2/yandex_client)

# YandexClient

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yandex_client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yandex_client

## Usage

### [Auth](https://yandex.ru/dev/oauth/doc/dg/concepts/about-docpage/)
```ruby
cli = YandexClient::Auth::Client.new
```

[create_token](https://tech.yandex.ru/oauth/doc/dg/reference/auto-code-client-docpage/#auto-code-client__get-token)
```ruby
cli.create_token(code: 'your_code')
```

[refresh_token](https://yandex.ru/dev/oauth/doc/dg/reference/refresh-client-docpage/)
```ruby
cli.refresh_token(refresh_token: 'your_token')
```

### [Passport](https://tech.yandex.ru/passport/doc/dg/reference/)
```ruby
cli = YandexClient::Passport::Client.new(access_token: 'your_access_token')
```

[info](https://yandex.ru/dev/passport/doc/dg/reference/request-docpage/)
```ruby
cli.info
```

### [Yandex Disk WebDav](https://yandex.ru/dev/disk/doc/dg/concepts/quickstart-docpage/)
```ruby
cli = YandexClient::Dav::Client.new(access_token: 'your_token')
```

[put](https://yandex.ru/dev/disk/doc/dg/reference/put-docpage/)
```ruby
cli.put(file: '1.txt', name: '/a/b/c/1.txt')
```

[delete](https://yandex.ru/dev/disk/doc/dg/reference/delete-docpage/)
```ruby
cli.delete(name: '/a/b/c/1.txt')
```

[mkcol](https://yandex.ru/dev/disk/doc/dg/reference/mkcol-docpage/)
```ruby
cli.mkcol(name: '/a/b/c')
```

[file props](https://yandex.ru/dev/disk/doc/dg/reference/property-request-docpage/)
```ruby
cli.propfind(name: '/a/dip.yml', depth: 0)
```

[list files in dir](https://yandex.ru/dev/disk/doc/dg/reference/property-request-docpage/)
```ruby
cli.propfind(name: '/a', depth: 1)
```

[account free space and quota](https://yandex.ru/dev/disk/doc/dg/reference/property-request-docpage/)
```ruby
cli.propfind(name: '/', quota: true)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Development with docker

* Install docker and docker-compose
* Install [dip](https://github.com/bibendi/dip)
```hash
gem install dip
``` 
* Prepare the the test environment
```bash
dip provision
```
* Run tests
```bash
dip rspec
```

## TODO
* docs...

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yamax2/yandex_client.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
