# Full Request Logger

Easy access to full request logs via a web UI.

## Installation

```ruby
# Gemfile
gem 'full_request_logger'
```

## Configuration

Add to development.rb and/or production.rb. Default TTL is 10 minutes and default Redis is localhost, 
but both can be overwritten. Only configuration needed is the enabled setting.

```ruby
config.full_request_logger.enabled = true
config.full_request_logger.ttl     = 1.hour
config.full_request_logger.redis   = { host: "127.0.0.1", port: 36379, timeout: 1 }
```

The request logs access can be protected behind http basic by adding the following credentials
(using `./bin/rails credentials:edit --environment production`):

```
full_request_logger:
  name: someone
  password: something
```

## Usage

Access request logs via /rails/conductor/full_request_logger/request_logs/:id where id is the X-Request-Id.

## License

Name of Person is released under the [MIT License](https://opensource.org/licenses/MIT).
