# YandexPhotoStorage

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yandex_photo_storage'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yandex_photo_storage

## Usage

TODO: Write usage instructions here

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
* Run rails console
```bash
dip rails_console
```
* Run psql
```bash
dip psql
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yamax2/yandex_photo_storage.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
