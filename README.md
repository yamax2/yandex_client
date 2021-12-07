# YandexClient

## Installation

Add this line to your application's Gemfile:
```ruby
gem 'yandex_client', '>= 1'
```

And then execute:
```bash
$ bundle install
```

Or install it yourself as:
```bash
$ gem install yandex_client
```

## Disk webdav

https://tech.yandex.ru/disk/doc/dg/reference/put-docpage/

Chainable client:
```ruby
YandexClient::Dav['your_access_token']
    .put('1.txt', '/a/b/c/1.txt')
    .put(File.open('1.txt', 'rb'), '/path/to/1.txt')
    .put(Tempfile.new.tap { |t| t.write('say ni'); t.rewind }, '/path/to/tmp.txt')
    .delete('/a/b/c/1.txt')
    .mkcol('/a/b/c')
    .propfind('/a/dip.yml', depth: 0)
    .propfind('/a', depth: 1)
    .propfind.to_a
```

## Disk rest api

https://yandex.ru/dev/disk/api/reference/capacity-docpage/
https://yandex.ru/dev/disk/api/reference/content-docpage/

```ruby
YandexClient::Disk['access_token'].info
YandexClient::Disk['access_token'].download_url('path/to/file')
YandexClient::Disk['access_token'].upload_url('path/to/file', overwrite: false)
YandexClient::Disk['access_token'].move('path/to/file', 'new_path/to/new_file', overwrite: false)
```

## Auth

https://tech.yandex.ru/oauth/doc/dg/reference/refresh-client-docpage/
https://tech.yandex.ru/oauth/doc/dg/reference/auto-code-client-docpage/#auto-code-client__get-token

```ruby
YandexClient.auth.create_token('9388894')
YandexClient.auth.refresh_token('refresh_token')
```

## Passport

https://tech.yandex.ru/passport/doc/dg/reference/request-docpage/

```ruby
YandexClient::Passport::Client['access_token'].info
```
